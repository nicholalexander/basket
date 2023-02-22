# frozen_string_literal: true

class DummyGroceryBasket
  include Basket::Batcher
  basket_options size: 2

  def perform
    puts "Checkout"
  end
end

RSpec.describe Basket do
  it "has a version number" do
    expect(Basket::VERSION).not_to be nil
  end

  it "will do something useful in the future" do
    expect(true).to eq(true)
  end

  it "will perform an action when the basket is full" do
    Basket.config

    stubbed_basket = DummyGroceryBasket.new
    allow(DummyGroceryBasket).to receive(:new).and_return(stubbed_basket)
    allow(stubbed_basket).to receive(:perform).and_call_original

    Basket.add("DummyGroceryBasket", :milk)
    Basket.add("DummyGroceryBasket", :cookies)

    expect(DummyGroceryBasket.basket_options_hash).to eq({size: 2})
    expect(stubbed_basket).to have_received(:perform)
  end
end
