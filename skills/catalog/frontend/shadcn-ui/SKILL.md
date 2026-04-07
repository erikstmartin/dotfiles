---
name: shadcn-ui
description: Use when setting up or using shadcn/ui components (install, configure, themes, forms, dialogs, tables). Not for non-React UI frameworks.
---

# shadcn/ui Integration Workflow

shadcn/ui copies component source into your project — you own and edit the code directly. Components are built on Radix UI primitives + Tailwind CSS.

## 1. Setup Workflow

### New project

```bash
npx create-next-app@latest my-app --typescript --tailwind --eslint --app
cd my-app
npx shadcn@latest init
```

The init prompt configures: style (Default/New York), base color, CSS variables vs Tailwind classes, and component path (`src/components/ui/`).

### Existing project

```bash
# Prereqs: Tailwind already configured
npm install tailwindcss-animate class-variance-authority clsx tailwind-merge lucide-react
npx shadcn@latest init
```

After init, verify `components.json` exists and `globals.css` has the CSS variable block:

```css
@layer base {
  :root {
    --background: 0 0% 100%;
    --foreground: 222.2 84% 4.9%;
    --primary: 222.2 47.4% 11.2%;
    --primary-foreground: 210 40% 98%;
    --radius: 0.5rem;
    /* ... other vars added by init */
  }
  .dark { /* dark mode overrides */ }
}
```

Verify `tailwind.config.js` has `darkMode: ["class"]` and `plugins: [require("tailwindcss-animate")]`.

Verify `tsconfig.json` has path alias:
```json
{ "paths": { "@/*": ["./src/*"] } }
```

---

## 2. Component Integration Workflow

### Install a component

```bash
npx shadcn@latest add button
npx shadcn@latest add button input form card dialog select  # multiple at once
```

This copies files into `src/components/ui/` and installs any missing `@radix-ui/*` deps.

### Import and use

```tsx
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
```

### Components that need a provider in the root layout

Some components (Toast, Tooltip) require a provider. Add once to `app/layout.tsx`:

```tsx
import { Toaster } from "@/components/ui/toaster"

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" suppressHydrationWarning>
      <body className="min-h-screen bg-background font-sans antialiased">
        {children}
        <Toaster />
      </body>
    </html>
  )
}
```

Then trigger toasts from any client component:

```tsx
"use client"
import { useToast } from "@/components/ui/use-toast"

const { toast } = useToast()
toast({ title: "Saved", description: "Changes persisted." })
toast({ variant: "destructive", title: "Error", description: "Something went wrong." })
```

---

## 3. Customization Workflow

### Change theme colors

Edit CSS variables in `globals.css` — changes apply to all components automatically:

```css
:root {
  --primary: 262 83% 58%;           /* purple instead of default */
  --primary-foreground: 0 0% 100%;
  --radius: 0.75rem;                /* rounder corners globally */
}
```

Use [ui.shadcn.com/themes](https://ui.shadcn.com/themes) to generate a full variable set.

### Add a custom variant to a component

Open the copied file directly (e.g., `src/components/ui/button.tsx`) and extend the `cva` config:

```tsx
const buttonVariants = cva("inline-flex items-center ...", {
  variants: {
    variant: {
      default: "bg-primary text-primary-foreground hover:bg-primary/90",
      // Add your variant:
      brand: "bg-gradient-to-r from-violet-500 to-fuchsia-500 text-white hover:opacity-90",
    },
  },
})
```

Use it: `<Button variant="brand">Upgrade</Button>`

### Override a component's styles ad-hoc

Pass `className` — it merges via `cn()` (tailwind-merge), so your classes win over defaults:

```tsx
<Button className="w-full rounded-full text-lg h-14">Full-width pill</Button>
```

---

## 4. Complete Examples

### Example A: Login form with validation

Install deps: `npx shadcn@latest add form input button card`

```tsx
"use client"

import { zodResolver } from "@hookform/resolvers/zod"
import { useForm } from "react-hook-form"
import { z } from "zod"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Form, FormControl, FormField, FormItem, FormLabel, FormMessage } from "@/components/ui/form"
import { Input } from "@/components/ui/input"

const schema = z.object({
  email: z.string().email("Invalid email"),
  password: z.string().min(8, "Min 8 characters"),
})

export function LoginForm() {
  const form = useForm<z.infer<typeof schema>>({
    resolver: zodResolver(schema),
    defaultValues: { email: "", password: "" },
  })

  function onSubmit(values: z.infer<typeof schema>) {
    console.log(values) // replace with your auth call
  }

  return (
    <Card className="w-[380px]">
      <CardHeader><CardTitle>Sign in</CardTitle></CardHeader>
      <CardContent>
        <Form {...form}>
          <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4">
            <FormField control={form.control} name="email" render={({ field }) => (
              <FormItem>
                <FormLabel>Email</FormLabel>
                <FormControl><Input type="email" placeholder="you@example.com" {...field} /></FormControl>
                <FormMessage />
              </FormItem>
            )} />
            <FormField control={form.control} name="password" render={({ field }) => (
              <FormItem>
                <FormLabel>Password</FormLabel>
                <FormControl><Input type="password" {...field} /></FormControl>
                <FormMessage />
              </FormItem>
            )} />
            <Button type="submit" className="w-full">Sign in</Button>
          </form>
        </Form>
      </CardContent>
    </Card>
  )
}
```

Key pattern: `FormField` wraps each input, `FormMessage` renders Zod errors automatically, spread `{...field}` onto the input.

### Example B: Confirmation dialog

Install: `npx shadcn@latest add dialog button`

```tsx
"use client"

import { useState } from "react"
import { Button } from "@/components/ui/button"
import {
  Dialog, DialogContent, DialogDescription,
  DialogFooter, DialogHeader, DialogTitle, DialogTrigger,
} from "@/components/ui/dialog"

export function DeleteConfirm({ onConfirm }: { onConfirm: () => void }) {
  const [open, setOpen] = useState(false)

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger asChild>
        <Button variant="destructive">Delete item</Button>
      </DialogTrigger>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Are you sure?</DialogTitle>
          <DialogDescription>This action cannot be undone.</DialogDescription>
        </DialogHeader>
        <DialogFooter>
          <Button variant="outline" onClick={() => setOpen(false)}>Cancel</Button>
          <Button variant="destructive" onClick={() => { onConfirm(); setOpen(false) }}>Delete</Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  )
}
```

Key pattern: `DialogTrigger asChild` passes the trigger role to your button without extra DOM nodes. Control open state manually when you need programmatic close.

---

## 5. Common Pitfalls

**Missing `"use client"`** — Radix-based components use hooks and event handlers; they fail in RSC without the directive. Add `"use client"` to any file that imports interactive shadcn components.

**`cn()` not found** — Init generates `src/lib/utils.ts` with the `cn` helper. If you moved files, update the import path in each component file.

**Form inputs not updating** — Always spread `{...field}` from `render={({ field }) => ...}`. Omitting it breaks React Hook Form's registration.

**Select value not binding in forms** — Use `onValueChange={field.onChange}` (not `onChange`) and `defaultValue={field.value}` on the `<Select>` element, not `<SelectTrigger>`.

**Dark mode not working** — `tailwind.config.js` must have `darkMode: ["class"]`. Toggle by adding/removing the `dark` class on `<html>`.

**Stale component code after shadcn update** — Components are snapshots; re-run `npx shadcn@latest add <component>` to get updates, but this overwrites customizations. Diff before overwriting.
