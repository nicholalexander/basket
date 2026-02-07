# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Thread safety for MemoryBackend using MonitorMixin with synchronized access to all public methods
- Per-queue locking (`with_lock`) in BackendAdapter interface for atomic push-check-perform-clear cycles
- HandleAdd atomicity via `with_lock` to prevent double-perform when concurrent threads hit the batch threshold
- Per-class backend configuration via `basket_options size: N, backend: :memory` or `:redis`
- `Basket.queue_collection_for` to manage per-backend queue collection instances
- `Configuration.resolve_backend` class method for resolving backend symbols to classes
- RedisBackend `with_lock` implementation using atomic Redis advisory locking with SET EX NX
- YARD documentation for all public methods across all production files
- Full RBS type signatures in `sig/basket.rbs` for all classes and modules
- Concurrency test suite for MemoryBackend (concurrent push, read-while-write, remove, search, push+clear)
- Concurrency test suite for HandleAdd (exactly-once perform, multi-batch correctness, stress testing)
- Per-class backend configuration test suite (isolation, fallback, clear_all)

### Changed
- MemoryBackend now includes MonitorMixin; `initialize` calls `super()` to set up the monitor
- HandleAdd `call` wraps push-check-perform-clear in `@queue_collection.with_lock(@queue)`
- HandleAdd resolves per-class backend before falling back to global `Basket.config.backend`
- `Batcher#batch` uses per-instance `@queue_collection` when set, falls back to `Basket.queue_collection`
- `Configuration#backend=` delegates to `Configuration.resolve_backend`
- `Basket.clear_all` now also clears per-backend queue collections
- `Element::InvalidElement` now inherits from `Basket::Error` instead of `StandardError`
- `Basket.search`, `Basket.remove`, and `Basket.peek` now route to per-class backends automatically
- Test suite expanded from 116 to 146 examples with 99%+ coverage

### Fixed
- BackendAdapter base class now raises `NotImplementedError` for all abstract methods including `search`, `remove`, and `with_lock`
- MemoryBackend `remove` uses explicit nil-checks instead of bare rescue
- RedisBackend `remove` has nil guard before calling `.to_json`
- HandleAdd uses `instance_variable_set` instead of `define_singleton_method` for setting element/error
- HandleAdd `maybe_raise_basket_error` uses `is_a?` instead of `instance_of?` for proper subclass matching
- HandleAdd `basket_full?` uses `>=` instead of `==` for defensive threshold checking
- MemoryBackend `push` uses `<<` instead of `<<=`
- MemoryBackend `read` returns `[]` for non-existent queues instead of nil
- MemoryBackend `search` returns `[]` for non-existent queues instead of crashing
- QueueCollection `data` normalizes through `Element.from_queue` for both backends
- `Element#==` has `respond_to?(:to_h)` guard to prevent NoMethodError
- Removed duplicate `Basket::Error` class definition from `lib/basket.rb`

## [0.0.7] - 2023-04-24

### Changed
- Use shared queue collection across the module
- Use string-based queue names instead of symbols in tests
- Loop through backends in queue collection specs

## [0.1.0] - 2023-02-15

- Initial release
