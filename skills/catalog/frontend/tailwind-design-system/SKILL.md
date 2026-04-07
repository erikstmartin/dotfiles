---
name: tailwind-design-system
description: Use for Tailwind v4 design systems: tokens, component libraries, and responsive patterns.
---

# Tailwind Design System (v4)

Build a production design system with Tailwind CSS v4 using CSS-first configuration, semantic tokens, and CVA components.

## 1. Design System Setup

**Step 1 — Install dependencies:**
```bash
npm install tailwindcss@next @tailwindcss/vite clsx tailwind-merge class-variance-authority
```

**Step 2 — Replace tailwind.config.ts with CSS-first config.** In v4 there is no config file; everything lives in CSS.

**Step 3 — Create `src/styles/globals.css`:**
```css
@import "tailwindcss";

/* Dark mode via class on <html> */
@custom-variant dark (&:where(.dark, .dark *));

@theme { /* tokens go here — see Section 2 */ }

@layer base {
  * { @apply border-border; }
  body { @apply bg-background text-foreground antialiased; }
}
```

**Step 4 — Create `src/lib/utils.ts`:**
```ts
import { type ClassValue, clsx } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}
```

---

## 2. Token Definition Workflow

Tokens follow a three-level hierarchy:
```
Brand value (oklch literal) → Semantic token (--color-primary) → Utility class (bg-primary)
```

**Step 1 — Define semantic color tokens in `@theme`:**
```css
@theme {
  /* light-mode defaults */
  --color-background:        oklch(100% 0 0);
  --color-foreground:        oklch(14.5% 0.025 264);
  --color-primary:           oklch(14.5% 0.025 264);
  --color-primary-foreground: oklch(98% 0.01 264);
  --color-muted:             oklch(96% 0.01 264);
  --color-muted-foreground:  oklch(46% 0.02 264);
  --color-destructive:       oklch(53% 0.22 27);
  --color-border:            oklch(91% 0.01 264);
  --color-ring:              oklch(14.5% 0.025 264);
  --color-card:              oklch(100% 0 0);
  --color-card-foreground:   oklch(14.5% 0.025 264);
}
```

**Step 2 — Override tokens in `.dark` for dark mode:**
```css
.dark {
  --color-background:        oklch(14.5% 0.025 264);
  --color-foreground:        oklch(98% 0.01 264);
  --color-primary:           oklch(98% 0.01 264);
  --color-primary-foreground: oklch(14.5% 0.025 264);
  --color-muted:             oklch(22% 0.02 264);
  --color-muted-foreground:  oklch(65% 0.02 264);
  --color-destructive:       oklch(42% 0.15 27);
  --color-border:            oklch(22% 0.02 264);
  --color-card:              oklch(14.5% 0.025 264);
  --color-card-foreground:   oklch(98% 0.01 264);
}
```

**Step 3 — Add spacing, radius, and animation tokens:**
```css
@theme {
  --radius-sm: 0.25rem;
  --radius-md: 0.375rem;
  --radius-lg: 0.5rem;

  --animate-fade-in: fade-in 0.2s ease-out;

  @keyframes fade-in {
    from { opacity: 0; }
    to   { opacity: 1; }
  }
}
```

**Step 4 — Clear Tailwind defaults when you want full control:**
```css
@theme {
  --color-*: initial; /* remove all built-in colors */
  /* now only your tokens exist */
}
```

---

## 3. Component Creation Workflow

**Step 1 — Install CVA for type-safe variants:**
```bash
npm install class-variance-authority @radix-ui/react-slot
```

**Step 2 — Create a base component with `cva(baseClasses, { variants })`:**
```ts
// src/components/ui/button.tsx
import { Slot } from "@radix-ui/react-slot";
import { cva, type VariantProps } from "class-variance-authority";
import { cn } from "@/lib/utils";

const buttonVariants = cva(
  // base — always applied
  "inline-flex items-center justify-center rounded-md text-sm font-medium transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50",
  {
    variants: {
      variant: {
        default:     "bg-primary text-primary-foreground hover:bg-primary/90",
        destructive: "bg-destructive text-destructive-foreground hover:bg-destructive/90",
        outline:     "border border-border bg-background hover:bg-muted",
        ghost:       "hover:bg-muted hover:text-foreground",
      },
      size: {
        default: "h-10 px-4 py-2",
        sm:      "h-9 px-3",
        lg:      "h-11 px-8",
        icon:    "size-10",
      },
    },
    defaultVariants: { variant: "default", size: "default" },
  }
);

export interface ButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof buttonVariants> {
  asChild?: boolean;
  ref?: React.Ref<HTMLButtonElement>;
}

export function Button({ className, variant, size, asChild = false, ref, ...props }: ButtonProps) {
  const Comp = asChild ? Slot : "button";
  return <Comp ref={ref} className={cn(buttonVariants({ variant, size, className }))} {...props} />;
}
```

**Step 3 — Build compound components for multi-part UI (e.g. Card):**
Each sub-element is its own function that accepts `className` + `ref`. Compose them at the call site.

**Step 4 — Wire up dark mode toggle:**
```ts
// src/providers/theme-provider.tsx
"use client";
import { createContext, useContext, useEffect, useState } from "react";

type Theme = "light" | "dark" | "system";
const ThemeCtx = createContext<{ theme: Theme; setTheme: (t: Theme) => void } | null>(null);

export function ThemeProvider({ children, defaultTheme = "system" }: { children: React.ReactNode; defaultTheme?: Theme }) {
  const [theme, setTheme] = useState<Theme>(defaultTheme);

  useEffect(() => {
    const stored = localStorage.getItem("theme") as Theme | null;
    if (stored) setTheme(stored);
  }, []);

  useEffect(() => {
    const resolved = theme === "system"
      ? (window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light")
      : theme;
    document.documentElement.classList.remove("light", "dark");
    document.documentElement.classList.add(resolved);
  }, [theme]);

  return (
    <ThemeCtx.Provider value={{ theme, setTheme: (t) => { localStorage.setItem("theme", t); setTheme(t); } }}>
      {children}
    </ThemeCtx.Provider>
  );
}

export const useTheme = () => {
  const ctx = useContext(ThemeCtx);
  if (!ctx) throw new Error("useTheme must be within ThemeProvider");
  return ctx;
};
```

---

## 4. Complete Examples

### Example A — Full token setup

```css
/* src/styles/globals.css */
@import "tailwindcss";
@custom-variant dark (&:where(.dark, .dark *));

@theme {
  --color-*: initial;

  --color-background:         oklch(100% 0 0);
  --color-foreground:         oklch(14.5% 0.025 264);
  --color-primary:            oklch(45% 0.2 260);
  --color-primary-foreground: oklch(98% 0.01 264);
  --color-muted:              oklch(96% 0.01 264);
  --color-muted-foreground:   oklch(46% 0.02 264);
  --color-destructive:        oklch(53% 0.22 27);
  --color-border:             oklch(91% 0.01 264);
  --color-ring:               oklch(45% 0.2 260);

  --radius-md: 0.375rem;
  --radius-lg: 0.5rem;

  --animate-fade-in: fade-in 0.2s ease-out;
  @keyframes fade-in { from { opacity: 0; } to { opacity: 1; } }
}

.dark {
  --color-background:         oklch(14.5% 0.025 264);
  --color-foreground:         oklch(98% 0.01 264);
  --color-primary:            oklch(65% 0.18 260);
  --color-primary-foreground: oklch(14.5% 0.025 264);
  --color-muted:              oklch(22% 0.02 264);
  --color-muted-foreground:   oklch(65% 0.02 264);
  --color-border:             oklch(22% 0.02 264);
}

@layer base {
  * { @apply border-border; }
  body { @apply bg-background text-foreground antialiased; }
}
```

### Example B — Card component system

```ts
// src/components/ui/card.tsx
import { cn } from "@/lib/utils";

export function Card({ className, ref, ...props }: React.HTMLAttributes<HTMLDivElement> & { ref?: React.Ref<HTMLDivElement> }) {
  return <div ref={ref} className={cn("rounded-lg border border-border bg-card text-card-foreground shadow-sm", className)} {...props} />;
}

export function CardHeader({ className, ref, ...props }: React.HTMLAttributes<HTMLDivElement> & { ref?: React.Ref<HTMLDivElement> }) {
  return <div ref={ref} className={cn("flex flex-col space-y-1.5 p-6", className)} {...props} />;
}

export function CardTitle({ className, ref, ...props }: React.HTMLAttributes<HTMLHeadingElement> & { ref?: React.Ref<HTMLHeadingElement> }) {
  return <h3 ref={ref} className={cn("text-2xl font-semibold leading-none tracking-tight", className)} {...props} />;
}

export function CardContent({ className, ref, ...props }: React.HTMLAttributes<HTMLDivElement> & { ref?: React.Ref<HTMLDivElement> }) {
  return <div ref={ref} className={cn("p-6 pt-0", className)} {...props} />;
}

export function CardFooter({ className, ref, ...props }: React.HTMLAttributes<HTMLDivElement> & { ref?: React.Ref<HTMLDivElement> }) {
  return <div ref={ref} className={cn("flex items-center p-6 pt-0", className)} {...props} />;
}

// Usage
// <Card>
//   <CardHeader><CardTitle>Settings</CardTitle></CardHeader>
//   <CardContent>…</CardContent>
//   <CardFooter><Button>Save</Button></CardFooter>
// </Card>
```

---

## 5. Common Pitfalls

| Pitfall | Fix |
|---|---|
| Using `tailwind.config.ts` | Move all config into `@theme {}` in CSS |
| Using `@tailwind base/utilities` | Replace with `@import "tailwindcss"` |
| Using `darkMode: "class"` config key | Use `@custom-variant dark (&:where(.dark, .dark *))` |
| Hardcoding colors (`bg-blue-500`) | Define semantic token + use `bg-primary` |
| `@keyframes` outside `@theme` | Move keyframes inside `@theme` so they're output with the token |
| `forwardRef` in React 19 | Pass `ref` as a regular prop directly |
| `h-10 w-10` for square elements | Use `size-10` shorthand |
| Arbitrary values (`w-[37px]`) | Add a custom token to `@theme` instead |
