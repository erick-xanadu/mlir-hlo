// RUN: stablehlo-opt -inline %s | stablehlo-translate --interpret
// RUN: diff <(stablehlo-translate --serialize --target=current %s | stablehlo-translate --deserialize | stablehlo-opt) <(stablehlo-opt %s)

module @jit_testcase {
  func.func public @main() -> tensor<i1> {
    %0:2 = call @inputs() : () -> (tensor<3x4xi8>, tensor<4x2xi8>)
    %1 = call @expected() : () -> tensor<3x2xi8>
    %2 = "stablehlo.dot_general"(%0#0, %0#1) {dot_dimension_numbers = #stablehlo.dot<lhs_contracting_dimensions = [1], rhs_contracting_dimensions = [0]>} : (tensor<3x4xi8>, tensor<4x2xi8>) -> tensor<3x2xi8>
    %3 = stablehlo.custom_call @check.eq(%2, %1) : (tensor<3x2xi8>, tensor<3x2xi8>) -> tensor<i1>
    return %3 : tensor<i1>
  }
  func.func private @inputs() -> (tensor<3x4xi8>, tensor<4x2xi8>) {
    %0 = stablehlo.constant dense<[[0, -1, -1, 0], [6, 0, 0, 2], [0, -5, -1, -2]]> : tensor<3x4xi8>
    %1 = stablehlo.constant dense<[[-5, 2], [-2, 1], [2, 4], [-3, 0]]> : tensor<4x2xi8>
    return %0, %1 : tensor<3x4xi8>, tensor<4x2xi8>
  }
  func.func private @expected() -> tensor<3x2xi8> {
    %0 = stablehlo.constant dense<[[0, -5], [-36, 12], [14, -9]]> : tensor<3x2xi8>
    return %0 : tensor<3x2xi8>
  }
}

