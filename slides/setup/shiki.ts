import { defineShikiSetup } from '@slidev/types'

// Default vitesse-light comments (#a0ada0) wash out on a projector.
export default defineShikiSetup(() => ({
  themes: {
    dark: 'github-dark',
    light: 'github-light',
  },
}))
