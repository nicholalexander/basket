# Basket Gem: Iterative Codebase Improvement Plan

## Status

### Completed

**Iteration 1: Error Handling & Internal Correctness** (commit `33803b2`)
- BackendAdapter: `raise NotImplementedError` + abstract `search`/`remove` methods
- MemoryBackend#remove: bare rescue replaced with explicit nil-checks
- RedisBackend#remove: nil guard before `.to_json`
- HandleAdd: `define_singleton_method` replaced with `instance_variable_set` + `attr_reader`
- HandleAdd#maybe_raise_basket_error: `instance_of?` replaced with `is_a?(Basket::Error)`
- HandleAdd#basket_full?: `==` changed to `>=` for defensive threshold
- Duplicate `Basket::Error` class removed from `lib/basket.rb`
- Element#==: `respond_to?(:to_h)` guard added
- MemoryBackend#push: `<<=` changed to `<<`

**Iteration 2: API Consistency & Expanded Test Coverage** (commits `61802e0`, `fac6bf8`)
- QueueCollection#data: normalized through `Element.from_queue` for both backends
- MemoryBackend#read: returns `[]` for non-existent queues instead of nil
- MemoryBackend#search: returns `[]` for non-existent queues instead of crash
- 18 new edge case tests (98 -> 116 examples)
- Backend adapter shared examples updated for search/remove

**Current test state:** 116 examples, 0 failures, 100% coverage

---

## Remaining Iterations

### Iteration 3: Thread Safety & Configuration

**3a. MemoryBackend thread safety**
- File: `lib/basket/backend_adapter/memory_backend.rb`
- Add `require "monitor"` and `include MonitorMixin`
- Call `super()` in `initialize` to set up the monitor
- Wrap all public methods (`push`, `read`, `search`, `remove`, `clear`, `length`, `data`) in `synchronize { }` blocks
- Tests: Add concurrency specs using threads to verify no data corruption

**3b. HandleAdd atomicity**
- File: `lib/basket/handle_add.rb`
- The push-check-perform-clear cycle in `call` (lines 12-19) is not atomic
- For MemoryBackend: add per-queue locking using the backend's monitor
- For RedisBackend: document the race window or implement SETNX advisory lock
- Consider adding a `with_lock(queue)` method to BackendAdapter interface
- Tests: Concurrent add tests that verify exactly one perform fires at threshold

**3c. Per-class backend configuration**
- Files: `lib/basket/batcher.rb`, `lib/basket/handle_add.rb`, `lib/basket/configuration.rb`
- Allow `basket_options size: 10, backend: :redis` in Batcher classes
- `basket_options_hash` should accept optional `:backend` key
- HandleAdd should check per-class backend first, fall back to global `Basket.config.backend`
- QueueCollection may need to support multiple backends or HandleAdd creates its own QueueCollection per call
- Tests: Verify a basket class with `:redis` backend uses Redis while default uses memory

**Review criteria:**
- All tests pass including concurrency tests
- Mutex-protected operations in MemoryBackend
- Per-class config works and falls back to global

---

### Iteration 4: YARD Documentation

Add `@param`, `@return`, `@raise`, `@example` to every public method across all production files.

**Files to document (10 total):**

| File | Public methods to document |
|------|---------------------------|
| `lib/basket.rb` | `config`, `configure`, `contents`, `peek`, `queue_collection`, `add`, `search`, `remove`, `clear_all` |
| `lib/basket/backend_adapter.rb` | `data`, `push`, `length`, `read`, `search`, `remove`, `clear` |
| `lib/basket/backend_adapter/memory_backend.rb` | `initialize`, `data`, `push`, `length`, `read`, `search`, `remove`, `clear` |
| `lib/basket/backend_adapter/redis_backend.rb` | `initialize`, `client`, `data`, `search`, `remove`, `push`, `length`, `clear`, `read` |
| `lib/basket/batcher.rb` | `basket_options`, `basket_options_hash`, `element`, `error`, `batch`, `perform`, `on_success`, `on_add`, `on_failure` |
| `lib/basket/configuration.rb` | All attr_accessors and `initialize` |
| `lib/basket/element.rb` | `from_queue`, `initialize`, `to_h`, `to_json`, `==` |
| `lib/basket/error.rb` | `Error`, `BasketNotFoundError`, `EmptyBasketError`, `ElementNotFoundError` |
| `lib/basket/handle_add.rb` | `call` (class method), `initialize` |
| `lib/basket/queue_collection.rb` | `initialize`, `push`, `length`, `read`, `search`, `remove`, `clear`, `data`, `reset_backend` |

**Review criteria:**
- `yard doc` produces zero warnings
- All public methods documented with @param, @return, @raise, @example

---

### Iteration 5: RBS Type Signatures

Expand `sig/basket.rbs` with full type coverage for all classes.

**Type signatures needed for:**
- `Basket` module (all class methods)
- `Basket::BackendAdapter` (abstract base)
- `Basket::BackendAdapter::MemoryBackend`
- `Basket::BackendAdapter::RedisBackend`
- `Basket::Batcher` (module with ClassMethods)
- `Basket::Configuration`
- `Basket::Element`
- `Basket::HandleAdd`
- `Basket::QueueCollection`
- All error classes

**Review criteria:**
- `rbs validate` passes
- Signatures match YARD annotations from Iteration 4

---

### Iteration 6+: Final Cleanup

Full-codebase review. Fix any remaining issues. Iterate until clean.

**Potential topics:**
- `frozen_string_literal: true` on all Ruby files (currently inconsistent)
- `.standard.yml` ruby_version alignment (currently targets 2.6, gemspec requires 3.0.6+)
- Consider making `redis`/`redis-namespace` optional dependencies (only needed for Redis backend)
- HandleAdd: `Object.const_get(@queue)` — consider safer class resolution for namespaced classes
- QueueCollection: `check_for_basket` uses `Object.const_defined?` which may not handle namespaces
- Batcher#on_failure: `raise error` when `@error` is nil gives confusing error
- Consider adding a `LockError` to the error hierarchy if Iteration 3 adds locking

---

## Swarm Setup

To resume, start Claude Code with swarm mode:
```bash
CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 claude
```

Create team `basket-dev` with three agents:
- `reviewer` (general-purpose) — code review, issue identification
- `coder` (general-purpose) — implementation
- `judge` (general-purpose) — validation, testing, verdicts

### Coordination Flow Per Iteration
```
1. Create review task → assign to reviewer
2. Reviewer confirms issues → mark review complete
3. Create implementation tasks (blocked by review) → assign to coder
4. Coder implements → marks tasks complete
5. Create judge task (blocked by implementations) → assign to judge
6. Judge runs tests, reviews diffs → posts PASS/FAIL
7. If FAIL → create fix tasks → coder fixes → judge re-reviews
8. If PASS → commit → next iteration
```

### Notes
- `bundle exec standardrb` is broken in Ruby 3.4 (missing `base64` gem) — skip linter check
- Always run `bundle exec rspec` for validation
- Current test suite: 116 examples, 0 failures, 100% coverage (968 LOC)
