// RUN-DISABLED: stablehlo-opt -inline %s | stablehlo-translate --interpret
// RUN: diff <(stablehlo-translate --serialize --target=current %s | stablehlo-translate --deserialize | stablehlo-opt) <(stablehlo-opt %s)

module @jit_testcase {
  func.func public @main() -> tensor<i1> {
    %0 = call @inputs() : () -> tensor<f32>
    %1 = call @expected() : () -> tensor<f32>
    %2 = stablehlo.reduce_precision %0, format = e8m23 : tensor<f32>
    %3 = stablehlo.custom_call @check.eq(%2, %1) : (tensor<f32>, tensor<f32>) -> tensor<i1>
    return %3 : tensor<i1>
  }
  func.func private @inputs() -> tensor<f32> {
    %0 = stablehlo.constant dense<2.073840e+00> : tensor<f32>
    return %0 : tensor<f32>
  }
  func.func private @expected() -> tensor<f32> {
    %0 = stablehlo.constant dense<2.073840e+00> : tensor<f32>
    return %0 : tensor<f32>
  }
}
