// RUN: stablehlo-opt -inline %s | stablehlo-translate --interpret
// RUN: diff <(stablehlo-translate --serialize --target=current %s | stablehlo-translate --deserialize | stablehlo-opt) <(stablehlo-opt %s)

module @jit_testcase {
  func.func public @main() -> tensor<i1> {
    %0:2 = call @inputs() : () -> (tensor<7x3x4xi1>, tensor<7x4xi1>)
    %1 = call @expected() : () -> tensor<7x3xi1>
    %2 = "stablehlo.dot_general"(%0#0, %0#1) {dot_dimension_numbers = #stablehlo.dot<lhs_batching_dimensions = [0], rhs_batching_dimensions = [0], lhs_contracting_dimensions = [2], rhs_contracting_dimensions = [1]>, precision_config = [#stablehlo<precision HIGH>, #stablehlo<precision HIGH>]} : (tensor<7x3x4xi1>, tensor<7x4xi1>) -> tensor<7x3xi1>
    %3 = stablehlo.custom_call @check.eq(%2, %1) : (tensor<7x3xi1>, tensor<7x3xi1>) -> tensor<i1>
    return %3 : tensor<i1>
  }
  func.func private @inputs() -> (tensor<7x3x4xi1>, tensor<7x4xi1>) {
    %0 = stablehlo.constant dense<true> : tensor<7x3x4xi1>
    %1 = stablehlo.constant dense<true> : tensor<7x4xi1>
    return %0, %1 : tensor<7x3x4xi1>, tensor<7x4xi1>
  }
  func.func private @expected() -> tensor<7x3xi1> {
    %0 = stablehlo.constant dense<true> : tensor<7x3xi1>
    return %0 : tensor<7x3xi1>
  }
}
