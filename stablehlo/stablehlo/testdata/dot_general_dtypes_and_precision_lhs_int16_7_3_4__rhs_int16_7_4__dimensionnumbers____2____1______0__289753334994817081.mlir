// RUN: stablehlo-opt -inline %s | stablehlo-translate --interpret
// RUN: diff <(stablehlo-translate --serialize --target=current %s | stablehlo-translate --deserialize | stablehlo-opt) <(stablehlo-opt %s)

module @jit_testcase {
  func.func public @main() -> tensor<i1> {
    %0:2 = call @inputs() : () -> (tensor<7x3x4xi16>, tensor<7x4xi16>)
    %1 = call @expected() : () -> tensor<7x3xi16>
    %2 = "stablehlo.dot_general"(%0#0, %0#1) {dot_dimension_numbers = #stablehlo.dot<lhs_batching_dimensions = [0], rhs_batching_dimensions = [0], lhs_contracting_dimensions = [2], rhs_contracting_dimensions = [1]>, precision_config = [#stablehlo<precision HIGH>, #stablehlo<precision HIGH>]} : (tensor<7x3x4xi16>, tensor<7x4xi16>) -> tensor<7x3xi16>
    %3 = stablehlo.custom_call @check.eq(%2, %1) : (tensor<7x3xi16>, tensor<7x3xi16>) -> tensor<i1>
    return %3 : tensor<i1>
  }
  func.func private @inputs() -> (tensor<7x3x4xi16>, tensor<7x4xi16>) {
    %0 = stablehlo.constant dense<[[[4, -4, 5, -4], [2, 1, 1, 2], [3, 0, 0, 0]], [[1, 5, 2, 0], [0, 1, 3, 4], [-1, 3, -1, 1]], [[-5, 4, 0, 0], [0, 3, 1, 0], [-2, -2, 1, 0]], [[0, 0, 0, -2], [-2, -1, -2, -4], [3, -1, 4, -3]], [[-2, 2, -3, -5], [-1, 3, -1, 0], [1, 1, 1, -1]], [[1, 1, -1, 1], [-3, -5, 2, -1], [-2, 0, 0, 0]], [[2, -4, 0, -2], [6, -1, 2, 0], [-4, -1, 5, -3]]]> : tensor<7x3x4xi16>
    %1 = stablehlo.constant dense<[[0, 0, 2, 0], [1, 0, -2, -2], [0, 3, -2, -2], [-1, 2, -2, -2], [0, -2, 5, -6], [0, -2, -1, 0], [0, 2, -1, 1]]> : tensor<7x4xi16>
    return %0, %1 : tensor<7x3x4xi16>, tensor<7x4xi16>
  }
  func.func private @expected() -> tensor<7x3xi16> {
    %0 = stablehlo.constant dense<[[10, 2, 0], [-3, -14, -1], [12, 7, -8], [4, 12, -7], [11, -11, 9], [-1, 8, 0], [-10, -4, -10]]> : tensor<7x3xi16>
    return %0 : tensor<7x3xi16>
  }
}
