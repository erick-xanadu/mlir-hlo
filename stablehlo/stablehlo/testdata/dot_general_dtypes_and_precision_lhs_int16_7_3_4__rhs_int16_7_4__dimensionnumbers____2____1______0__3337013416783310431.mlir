// RUN: stablehlo-opt -inline %s | stablehlo-translate --interpret
// RUN: diff <(stablehlo-translate --serialize --target=current %s | stablehlo-translate --deserialize | stablehlo-opt) <(stablehlo-opt %s)

module @jit_testcase {
  func.func public @main() -> tensor<i1> {
    %0:2 = call @inputs() : () -> (tensor<7x3x4xi16>, tensor<7x4xi16>)
    %1 = call @expected() : () -> tensor<7x3xi16>
    %2 = "stablehlo.dot_general"(%0#0, %0#1) {dot_dimension_numbers = #stablehlo.dot<lhs_batching_dimensions = [0], rhs_batching_dimensions = [0], lhs_contracting_dimensions = [2], rhs_contracting_dimensions = [1]>} : (tensor<7x3x4xi16>, tensor<7x4xi16>) -> tensor<7x3xi16>
    %3 = stablehlo.custom_call @check.eq(%2, %1) : (tensor<7x3xi16>, tensor<7x3xi16>) -> tensor<i1>
    return %3 : tensor<i1>
  }
  func.func private @inputs() -> (tensor<7x3x4xi16>, tensor<7x4xi16>) {
    %0 = stablehlo.constant dense<[[[0, -4, 1, 0], [0, -3, 3, 2], [2, -1, 2, 0]], [[-7, 1, 5, -2], [0, -3, 3, 3], [-2, 0, 2, 1]], [[0, 0, 0, 0], [1, -2, -3, 0], [0, 1, 1, 0]], [[0, -3, 3, 2], [0, 3, 0, 0], [0, 0, 1, -2]], [[-5, -3, 1, 4], [-1, -1, -2, -1], [4, 0, 1, 1]], [[0, 0, 0, 6], [4, 2, 3, 1], [0, -3, 6, -3]], [[-4, -4, 0, 5], [0, -2, 5, -3], [-3, -1, -3, 0]]]> : tensor<7x3x4xi16>
    %1 = stablehlo.constant dense<[[1, 0, 4, 0], [-4, -1, -1, -3], [-6, -1, 2, 0], [6, 3, 0, -2], [-3, 2, -5, -3], [4, 2, -1, 8], [0, 0, -2, -5]]> : tensor<7x4xi16>
    return %0, %1 : tensor<7x3x4xi16>, tensor<7x4xi16>
  }
  func.func private @expected() -> tensor<7x3xi16> {
    %0 = stablehlo.constant dense<[[4, 12, 10], [28, -9, 3], [0, -10, 1], [-13, 9, 4], [-8, 14, -20], [48, 25, -36], [-25, 5, 6]]> : tensor<7x3xi16>
    return %0 : tensor<7x3xi16>
  }
}

