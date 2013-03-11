class Vehicle < ActiveRecord::Base
  attr_accessor :raise_at
  attr_accessor :halt_at
  attr_accessor :fail_validate

  state_machine :state, :initial => :parked do
    before_transition :on => :ignite do |vehicle, transition, block|
      ap 'before transition'
      raise       if vehicle.raise_at == :before
      throw :halt if vehicle.halt_at  == :before
    end

    after_transition :on => :ignite do |vehicle, transition, block|
      ap 'after transition'
      raise       if vehicle.raise_at == :after
      throw :halt if vehicle.halt_at  == :after
    end

    after_failure :on => :ignite do |vehicle, transition, block|
      ap 'failure transition'
      raise       if vehicle.raise_at == :failure
      throw :halt if vehicle.halt_at  == :failure
    end

    around_transition do |vehicle, transition, block|
      ap 'around transition start'
      raise       if vehicle.raise_at == :around_before
      throw :halt if vehicle.halt_at  == :around_before
      block.call
      ap 'around transition finish'
      throw :halt if vehicle.halt_at  == :around_after
      raise       if vehicle.raise_at == :around_after
    end

    event :park do
      transition :idling => :parked
    end

    event :ignite do
      transition :parked => :idling
    end
  end

  before_validation do
    ap 'before validation'
    raise       if raise_at == :before_validation
    throw :halt if halt_at  == :before_validation
  end

  before_save do
    ap 'before save'
    raise       if raise_at == :before_save
    throw :halt if halt_at  == :before_save
  end

  after_save do
    ap 'after save'
    raise       if raise_at == :after_save
    throw :halt if halt_at  == :after_save
  end

  validate do
    ap 'validate'
    if fail_validate
      errors.add :base, 'validation error'
    else
      raise       if raise_at == :validate
      throw :halt if halt_at  == :validate
    end
  end
end
