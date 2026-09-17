//  ProductPricingTests.swift
//  TripStoreTests
//
//  Tests: price calculation, discounted price rounding, service fee, quantity math.

import XCTest
@testable import TripStore

final class ProductPricingTests: XCTestCase {

    // MARK: Product.discountedPrice

    func test_discountedPrice_withNoDiscount_returnsFullPrice() {
        let product = Product.stub(price: 50.0, discountPercentage: nil)
        XCTAssertEqual(product.discountedPrice, 50.0, accuracy: 0.001)
    }

    func test_discountedPrice_withZeroDiscount_returnsFullPrice() {
        let product = Product.stub(price: 200.0, discountPercentage: 0.0)
        XCTAssertEqual(product.discountedPrice, 200.0, accuracy: 0.001)
    }

    func test_discountedPrice_with10PercentDiscount() {
        // 100.0 - 10% = 90.0
        let product = Product.stub(price: 100.0, discountPercentage: 10.0)
        XCTAssertEqual(product.discountedPrice, 90.0, accuracy: 0.001)
    }

    func test_discountedPrice_withFractionalDiscount_isAccurate() {
        // 99.99 - 12.5% = 87.49125
        let product = Product.stub(price: 99.99, discountPercentage: 12.5)
        let expected = 99.99 * (1 - 12.5 / 100.0)
        XCTAssertEqual(product.discountedPrice, expected, accuracy: 0.0001)
    }

    @MainActor
    func test_serviceFee_withMultipleItemsAndQuantities() async {
        let vm = OrderViewModel()
        // Item A: price 40 x qty 2 = 80
        vm.addToCart(product: Product.stub(id: 1, price: 40.0), quantity: 2)
        // Item B: price 60 x qty 1 = 60
        vm.addToCart(product: Product.stub(id: 2, price: 60.0), quantity: 1)
        // subtotal = 140, service fee = 7, total = 147
        XCTAssertEqual(vm.subtotal, 140.0, accuracy: 0.001)
        XCTAssertEqual(vm.serviceFee, 7.0,   accuracy: 0.001)
        XCTAssertEqual(vm.total,     147.0,  accuracy: 0.001)
    }

    @MainActor
    func test_addToCart_incrementsQuantityForExistingProduct() async {
        let vm = OrderViewModel()
        let p = Product.stub(id: 99, price: 10.0)
        vm.addToCart(product: p, quantity: 1)
        vm.addToCart(product: p, quantity: 3)
        XCTAssertEqual(vm.cartItems.count, 1, "Duplicate product should not create a new cart line")
        XCTAssertEqual(vm.cartItems[0].quantity, 4)
        XCTAssertEqual(vm.subtotal, 40.0, accuracy: 0.001)
    }

    @MainActor
    func test_quantityValidation_zeroStock_marksProductOutOfStock() {
        let product = Product.stub(stock: 0)
        XCTAssertFalse(product.isInStock, "Product with stock=0 must be marked out of stock")
    }


    @MainActor
    func test_placeOrder_clearsCartAndRecordsOrder() async {
        let vm = OrderViewModel()
        vm.addToCart(product: Product.stub(id: 1, price: 80.0), quantity: 1)
        await vm.placeOrder()
        XCTAssertTrue(vm.cartItems.isEmpty, "Cart must be empty after placing order")
        XCTAssertFalse(vm.orders.isEmpty, "Order history must contain at least one order")
    }
}
