---
name: ruby-rails
description: Use for Rails apps: ActiveRecord/models, migrations, controllers/routes, background jobs, caching, and Hotwire. Not for non-Rails Ruby.
---

# Ruby on Rails

Idiomatic Rails development — conventions, ActiveRecord, and production patterns.

## Workflow

1. **Model** — schema + migrations + validations + scopes
2. **Controller** — thin controllers, strong params, respond_to
3. **Background** — ActiveJob with Sidekiq, idempotent + retry-safe
4. **Performance** — N+1 prevention, caching, counter caches
5. **Test** — RSpec/Minitest with FactoryBot, request specs for behavior

## Migration Example

```ruby
class AddEmailVerifiedToUsers < ActiveRecord::Migration[7.1]
  def change
    # Step 1: nullable column (safe to deploy before backfill)
    add_column :users, :email_verified, :boolean

    # Step 2: backfill in batches to avoid full-table lock
    User.in_batches.update_all(email_verified: false)

    # Step 3: enforce the constraint after backfill completes
    change_column_null :users, :email_verified, false, false
    change_column_default :users, :email_verified, false
  end
end
```

Always add indexes alongside foreign keys and query predicates. Use `add_index :orders, :customer_id` in the same migration as the column.

## ActiveRecord Patterns

```ruby
class Order < ApplicationRecord
  belongs_to :customer
  has_many :items, dependent: :destroy

  # Composable scopes — chain freely without N+1
  scope :recent,        -> { order(created_at: :desc) }
  scope :for_customer,  ->(id) { where(customer_id: id) }
  scope :pending,       -> { where(status: :pending) }
  scope :with_details,  -> { includes(:items, :customer) }

  # Enum for finite states — generates predicates like order.pending?
  enum :status, { pending: 0, confirmed: 1, shipped: 2, delivered: 3 }

  validates :customer, presence: true
  validates :status, presence: true
end
```

Controller stays thin — it composes scopes, it doesn't implement business logic:
```ruby
class OrdersController < ApplicationController
  def index
    @orders = Order.with_details.recent.for_customer(params[:customer_id])
  end

  def create
    @order = Order.new(order_params)
    if @order.save
      redirect_to @order, notice: "Order created"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def order_params
    params.require(:order).permit(:customer_id, :notes, items_attributes: [:product_id, :quantity])
  end
end
```

## Background Job Pattern

```ruby
class ProcessOrderJob < ApplicationJob
  queue_as :default
  retry_on ActiveRecord::Deadlocked, wait: 5.seconds, attempts: 3
  discard_on ActiveRecord::RecordNotFound

  def perform(order_id)
    order = Order.find_by(id: order_id)
    return unless order&.pending?  # Idempotent guard — safe to re-run

    ActiveRecord::Base.transaction do
      order.confirm!
      InventoryService.reserve(order)
    end

    OrderMailer.confirmation(order).deliver_later
  end
end
```

Pass IDs, not full objects — Active Job serializes records by ID and re-loads on execution to avoid stale data.

## Caching

```ruby
# Fragment caching with automatic expiry via cache_key_with_version
<% cache @order do %>
  <%= render @order %>
<% end %>

# Russian-doll: parent key changes when child changes
<% cache [@customer, @customer.orders.maximum(:updated_at)] do %>
  <% @customer.orders.each do |order| %>
    <% cache order do %><%= render order %><% end %>
  <% end %>
<% end %>
```

For low-traffic read-heavy data, use `Rails.cache.fetch`:
```ruby
def self.featured
  Rails.cache.fetch("products/featured", expires_in: 1.hour) do
    where(featured: true).with_details.to_a
  end
end
```

## Pitfalls
- N+1 queries — always use `includes` (or `preload`/`eager_load`) for associations rendered in views or serializers; use Bullet gem to catch them in development
- Missing DB constraints — Rails validations alone don't prevent race conditions; add `add_index :users, :email, unique: true` and foreign key constraints at the DB level
- Fat controllers — extract domain logic to models, service objects, or form objects; controllers should only coordinate
- `dependent: :destroy` on large associations triggers callbacks for every record — use `dependent: :delete_all` or schedule a background cleanup job for tables with millions of rows
- `update_all` and `delete_all` skip callbacks and validations — use `find_each { |r| r.update(...) }` when callbacks matter, but be aware of the performance tradeoff
- Passing ActiveRecord objects into jobs — they serialize as `{ "_aj_globalid": "gid://..." }` and re-query on load; if the record is deleted before the job runs, it raises unless you `discard_on ActiveRecord::RecordNotFound`
