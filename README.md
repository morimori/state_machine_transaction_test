[state_machine](https://github.com/pluginaweek/state_machine) のトランザクションについて検証
============================================

```ruby
v = Vehicle.create
```

正常時
------
```ruby
v.ignite # => true
# BEGIN
"before transition"
"around transition start"
"before validation"
"validate"
"before save"
# UPDATE
"around transition finish"
"after transition"
"after save"
# COMMIT
```

バリデーション失敗
------------------
```ruby
v.fail_validate = true
v.ignite # => false
# BEGIN
"before transition"
"around transition start"
"before validation"
"validate"
"failure transition"
# ROLLBACK
```

raise
-----

### before_transition コールバック内
```ruby
v.raise_at = :before
v.ignite # => RuntimeError
# BEGIN
"before hook"
# ROLLBACK
```

### around_transition コールバック開始時
```ruby
v.raise_at = :around_before
v.ignite # => RuntimeError
# BEGIN
"before hook"
"around transition start"
# ROLLBACK
```

### before_validation コールバック内
```ruby
v.raise_at = :before_validation
v.ignite # => RuntimeError
# BEGIN
"before hook"
"around transition start"
"before validation"
# ROLLBACK
```

### バリデーション中
```ruby
v.raise_at = :validate
v.ignite # => RuntimeError
# BEGIN
"before hook"
"around transition start"
"before validation"
"validate"
# ROLLBACK
```

### before_save コールバック内
```ruby
v.raise_at = :before_save
v.ignite # => RuntimeError
# BEGIN
"before hook"
"around transition start"
"before validation"
"validate"
"before save"
# ROLLBACK
```

### around_transition コールバック終了時
```ruby
v.raise_at = :around_after
v.ignite # => RuntimeError
# BEGIN
"before transition"
"around transition start"
"before validation"
"validate"
"before save"
# UPDATE
"around transition finish"
# ROLLBACK
```

### after_transition コールバック内
```ruby
v.raise_at = :after
v.ignite # => RuntimeError
# BEGIN
"before transition"
"around transition start"
"before validation"
"validate"
"before save"
# UPDATE
"around transition finish"
"after transition"
# ROLLBACK
```

### after_save コールバック内
```ruby
v.raise_at = :after_save
v.ignite # => RuntimeError
# BEGIN
"before transition"
"around transition start"
"before validation"
"validate"
"before save"
# UPDATE
"around transition finish"
"after transition"
"after save"
# ROLLBACK
```

halt
----

### before_transition コールバック内
```ruby
v.halt_at = :before
v.ignite # => false
# BEGIN
"before transition"
"failure transition"
# ROLLBACK
```

### around_transition コールバック開始時
```ruby
v.halt_at = :around_before
v.ignite # => false
# BEGIN
"before transition"
"around transition start"
"failure transition"
# ROLLBACK
```

### before_validation コールバック内
```ruby
v.halt_at = :before_validation
v.ignite # => false
# BEGIN
"before transition"
"around transition start"
"before validation"
# ROLLBACK
```
* **after_failure が呼ばれない**

### バリデーション中
```ruby
v.halt_at = :validate
v.ignite # => false
# BEGIN
"before transition"
"around transition start"
"before validation"
"validate"
# ROLLBACK
```
* **after_failure が呼ばれない**

### before_save コールバック内
```ruby
v.halt_at = :before_save
v.ignite # => false
# BEGIN
"before hook"
"around transition start"
"before validation"
"validate"
"before save"
"after save"
# ROLLBACK
```
* **after_failure が呼ばれない**
* **after_save が呼ばれる**

### around_transition コールバック終了時
```ruby
v.halt_at = :around_after
v.ignite # => true
# BEGIN
"before transition"
"around transition start"
"before validation"
"validate"
"before save"
# UPDATE
"around transition finish"
"after save"
# COMMIT
```
* **after_failure が呼ばれない**
* **after_save が呼ばれる**
* **コミットに成功する**

### after_transition コールバック内
```ruby
v.halt_at = :after
v.ignite # => true
# BEGIN
"before transition"
"around transition start"
"before validation"
"validate"
"before save"
# UPDATE
"around transition finish"
"after transition"
"after save"
# COMMIT
```
* **after_failure が呼ばれない**
* **after_save が呼ばれる**
* **コミットに成功する**

### after_save コールバック内
```ruby
v.halt_at = :after_save
v.ignite # => ArgumentError: uncaught throw :halt
# BEGIN
"before transition"
"around transition start"
"before validation"
"validate"
"before save"
# UPDATE
"around transition finish"
"after transition"
"after save"
# ROLLBACK
```
* **state_machine の管理外で throw されるので例外が発生して、結果的にコミットに失敗**
