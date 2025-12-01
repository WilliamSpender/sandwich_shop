You are implementing "edit item in cart" for a Flutter sandwich shop app. Current screens: Order screen (create sandwich) and Cart screen (list items). Requirements:

1) Entry point
   1.1) From `Cart` screen each cart row must expose an "Edit" action (icon button or tap) that opens an Edit Item screen (full page or modal) pre-filled with that item's current values.

2) Edit Item screen - UI
   2.1) Fields (pre-filled):
   2.1.1) Sandwich type (filling) - same selector used on Order screen.
   2.1.2) Size - toggle or segmented control: 6-inch and Footlong.
   2.1.3) Bread type - dropdown or selector mirroring Order screen options.
   2.1.4) Quantity - stepper with \`+\` and \`-\` and direct numeric entry; minimum allowed 1 in the UI (0 allowed only if implementing "remove" button).
   2.2) Actions: Save and Cancel (and optional Remove item).

3) Expected runtime behavior on user actions
   3.1) Cancel: dismiss with no change.
   3.2) Remove: remove the item from the cart, recalc price, navigate back, show confirmation (snackbar).
   3.3) Save:
   3.3.1) Validate quantity >= 1; show inline error if invalid.
   3.3.2) Construct a new \`Sandwich\` instance with the selected attributes (type, size, bread).
   3.3.3) If new sandwich equals the original sandwich (same attributes) update the existing entry quantity to the new quantity.
   3.3.4) If new sandwich differs:
   3.3.4.1) If cart already contains an item equal to the new sandwich: merge by summing quantities (existing + new) and remove the original item.
   3.3.4.2) Else: remove the original item and insert the new sandwich with the edited quantity.
   3.3.5) If user sets quantity to 0 (if allowed) treat as removal.
   3.3.6) After modification, recalc total via \`PricingRepository.calculatePrice\` and update cart UI immediately. Show success snackbar and close the edit screen.

4) Data/API implementation guidance
   4.1) Add a clear cart API method:
- \`Cart.updateItem(Sandwich oldItem, Sandwich newItem, int newQuantity)\`
  Behavior: apply the merging/removal logic described in 3.3.
  4.2) Ensure \`Sandwich\` equality and hashCode are implemented based on all attributes used as map keys.
  4.3) Use existing \`PricingRepository\` to recompute total after updates (pass \`isFootlong\` and quantity).
  4.4) Keep cart mutations synchronous on the model but update UI reactively (ChangeNotifier, Stream, Provider, Riverpod, etc., depending on app architecture). Wrap longer operations in async with a loading indicator.

5) UX / edge cases / concurrency
   5.1) Show a loading indicator on Save while performing updates (if async). Prevent double taps.
   5.2) If two edits happen concurrently (rare for local single-device), ensure update is atomic and final cart state uses merge logic.
   5.3) If new sandwich attributes match another cart item, merge quantities instead of creating duplicates.
   5.4) If equality for \`Sandwich\` is not currently implemented, failing to do so will create duplicate keys; update model first.

6) Tests to add
   6.1) Unit tests for \`Cart.updateItem\`:
   6.1.1) Update with same attributes updates quantity.
   6.1.2) Update into existing different item merges quantities and removes old entry.
   6.1.3) Update to unique new sandwich replaces key correctly.
   6.1.4) Update with quantity 0 removes item.
   6.1.5) Total recalculation uses \`PricingRepository\` values.
   6.2) Widget tests for Edit Item screen: prefill state, validation, save/cancel flows, merging behavior reflected in Cart screen.

7) Acceptance criteria
   7.1) From Cart screen tap Edit opens edit UI with correct pre-filled values.
   7.2) Saving applies edits and cart UI updates instantly, with totals recalculated.
   7.3) Editing to match another item merges quantities and does not leave duplicates.
   7.4) Cancel leaves cart unchanged.
   7.5) Unit and widget tests covering the above are added.

Provide the specific code edits required (Cart method signature and implementation, Edit Item widget, wiring to Cart screen, and tests) in a follow-up request and include file paths and minimal diffs.
