# Edit Item in Cart — Requirements

## Overview
Purpose: Add an "Edit Item" feature to the Flutter sandwich shop app so users can change an existing cart item's sandwich attributes and quantity. The feature must present a pre-filled Edit Item screen, apply merge/removal logic when saving, recalculate totals, and update the cart UI reactively.

Scope: UI for launching and editing items, cart model API to perform atomic updates and merges, pricing recalculation integration, UX (loading, validation), and unit/widget tests.

---

## Subtask 1 \- Entry point (Cart UI)
Description:
- Expose an edit affordance for each cart row on the `Cart` screen (icon button and/or row tap).
- Tapping the affordance opens the Edit Item screen (full page or modal) pre\-filled with that row's current values.

Deliverables:
- Add edit button or make row tappable.
- Navigation to Edit Item screen with the cart item and its current quantity passed as arguments.

UX notes:
- Edit launch should be immediate and accessible.
- Support system back to cancel.

---

## Subtask 2 \- Edit Item screen \- UI & behavior
Description:
- Create an Edit Item screen that is pre\-filled and allows changing sandwich attributes and quantity.

Fields (pre\-filled):
- Sandwich type (filling): reuse selector from Order screen.
- Size: segmented control / toggle with options `6-inch` and `Footlong`.
- Bread type: dropdown / selector matching Order screen.
- Quantity: stepper with `+` and `-` and editable numeric field. UI must enforce minimum 1 (unless Remove button is implemented).

Actions:
- Save
- Cancel
- Optional: Remove (explicit remove button that sets quantity to 0 and removes the item)

Validation and UX:
- Inline validation for quantity (must be integer >= 1).
- Show inline error if quantity invalid.
- Disable Save while async update is running; show a loading indicator.
- Prevent double-tap / double-submit.

Behavior on user actions:
- Cancel: dismiss with no changes.
- Remove: remove item, recalc totals, navigate back, show confirmation snackbar.
- Save:
  - Validate quantity.
  - Construct a new `Sandwich` instance from selected attributes.
  - Call cart update API described below.
  - Refresh cart UI immediately (reactive).
  - Show success snackbar and close edit screen.

---

## Subtask 3 \- Cart API / Model changes
API:
- Add method:
  - `Cart.updateItem(Sandwich oldItem, Sandwich newItem, int newQuantity)`
Behavior (atomic, synchronous on model):
1. If `newQuantity <= 0`: remove `oldItem`.
2. If `newItem.equals(oldItem)`:
   - Update the existing entry's quantity to `newQuantity`.
   - If `newQuantity == 0`: remove the entry.
3. Else:
   - If cart contains an entry equal to `newItem`:
     - Merge: set existing newItem quantity = existing quantity + newQuantity.
     - Remove `oldItem` entry.
   - Else:
     - Remove `oldItem` entry.
     - Insert `newItem` with quantity `newQuantity`.

- After mutation, call `PricingRepository.calculatePrice(isFootlong: bool, quantity: int)` (or equivalent) to recompute item and total prices; update the cart total.

Model requirements:
- Implement `Sandwich.equals` and `hashCode` based on all attributes used to distinguish sandwiches (type/filling, size, bread, and any other relevant option).
- Cart internal data structure must support atomic updates (synchronous model mutation). If concurrency possible, ensure update is protected (mutex/lock) or leverage single-threaded UI model guarantees.

Reactive update:
- Cart should notify listeners immediately after mutation (e.g., ChangeNotifier, Stream, Provider, Riverpod). UI must observe and update totals and cart list.

Edge cases / concurrency:
- If two edits occur concurrently, ensure merge/removal logic yields consistent final state. Apply updates atomically on the model.

---

## Subtask 4 \- Pricing integration
Description:
- Use existing `PricingRepository` to recalc prices after cart changes.
- For each item update, call `calculatePrice` with `isFootlong` and `quantity` to compute item price, then update cart total.

Notes:
- Keep price calculation logic centralized in `PricingRepository`.
- Ensure the UI displays updated totals immediately after the cart change notification.

---

## Subtask 5 \- UX, error handling, and notifications
Loading and blocking:
- Show a loading indicator on Save while async operations run.
- Disable Save and Remove while operation is in progress.

Notifications:
- On success: show a snackbar "Item updated" or "Item removed" as appropriate.
- On validation failure: show inline error next to quantity input.
- On failure (rare): show error snackbar and keep edit screen open.

Accessibility:
- Ensure controls are reachable, labeled, and follow platform accessibility guidelines.

---

## Subtask 6 \- Tests
Unit tests for `Cart.updateItem`:
- Test A: Update with same attributes updates quantity.
- Test B: Update into existing different item merges quantities and removes the original entry.
- Test C: Update to unique new sandwich replaces key correctly.
- Test D: Update with quantity 0 removes item.
- Test E: Total recalculation uses `PricingRepository` values (mock `PricingRepository` to assert calls and totals).

Widget tests:
- Edit Item screen pre\-fills fields from selected cart item.
- Validation: quantity below 1 shows inline error and prevents save.
- Save flow: saving updates cart and closes the screen; cart UI shows updated totals and merged items when applicable.
- Cancel: no changes to cart.
- Remove: removes item and shows confirmation.

Test guidelines:
- Use dependency injection for `PricingRepository` to allow mocking.
- For widget tests, wrap widgets with the same Providers/State management used in the app.

---

## User Stories

1. As a shopper, I want to edit an item in my cart so I can change bread, size, or quantity without creating duplicate items.
2. As a shopper, I want the Edit Item screen pre\-filled with my item's current choices so I can quickly update only what I want.
3. As a shopper, I want the app to merge identical items when I edit one to match another, so my cart doesn’t contain duplicates.
4. As a shopper, I want validation on quantity and feedback if something is wrong so I don't accidentally set invalid quantities.
5. As a shopper, I want to remove an item from the cart from the Edit screen so I can delete items quickly.
6. As a developer, I want a single cart API method (`Cart.updateItem`) that encapsulates merge/removal logic so other code paths can reuse it and tests can verify behavior.

---

## Acceptance Criteria

Functional:
- From `Cart` screen, each row has an Edit affordance and tapping it opens Edit Item screen pre\-filled with correct sandwich attributes and quantity.
- Save validates quantity >= 1 (unless Remove button is explicitly used); invalid input shows an inline error and prevents save.
- Saving constructs a `Sandwich` from the chosen attributes and calls `Cart.updateItem(oldItem, newItem, newQuantity)`.
- `Cart.updateItem` implements the described merge/removal logic atomically and updates quantities or removes items correctly.
- If edited item matches an existing cart item, the app merges quantities and removes the original entry (no duplicates).
- If edited item differs and is unique, the original entry is removed and the new entry inserted with the edited quantity.
- Removing an item (via Remove or setting quantity 0 if supported) removes it, recalculates totals, and shows a confirmation snackbar.
- Totals are recalculated using `PricingRepository.calculatePrice` and the cart UI updates instantly after the operation.
- Edit screen shows a loading indicator while save/remove is in progress and prevents double submissions.
- Cancel dismisses without changing the cart.

Non\-functional / Tests:
- Unit tests for `Cart.updateItem` covering same attributes update, merging into existing item, replacing with unique item, removal on quantity 0, and price recalculation calls.
- Widget tests for Edit Item screen covering prefill, validation, save/cancel/remove flows, and merging observable in Cart screen.
- `Sandwich` equality and `hashCode` implemented based on all distinguishing attributes.

---

## Implementation checklist (subtasks)
1. UI: Add Edit affordance in `Cart` screen and navigation to Edit Item screen.
2. UI: Implement `EditItemScreen` with fields, validation, Save/Cancel/Remove, and loading state.
3. Model: Add `Cart.updateItem(Sandwich oldItem, Sandwich newItem, int newQuantity)` implementing merge/removal rules.
4. Model: Ensure `Sandwich.equals` and `hashCode` based on relevant fields.
5. Pricing: Integrate `PricingRepository.calculatePrice` after updates.
6. Tests: Add unit tests for `Cart.updateItem` and widget tests for Edit Item screen behavior.

---

## Risks and considerations
- If `Sandwich` equality is missing or incomplete, merge behavior will fail and duplicates will appear. Implement equality first.
- Concurrency: If the app supports multi\-device sync later, server reconciliation rules must match local merge semantics.
- UX: Decide whether quantity 0 is allowed via editing or only via an explicit Remove action; ensure UI/validation matches that choice.