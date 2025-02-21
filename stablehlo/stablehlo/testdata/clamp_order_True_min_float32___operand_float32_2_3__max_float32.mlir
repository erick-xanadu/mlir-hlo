// RUN: stablehlo-opt -inline %s | stablehlo-translate --interpret
// RUN: diff <(stablehlo-translate --serialize --target=current %s | stablehlo-translate --deserialize | stablehlo-opt) <(stablehlo-opt %s)

module @jit_testcase {
  func.func public @main() -> tensor<i1> {
    %0:3 = call @inputs() : () -> (tensor<f32>, tensor<2x3xf32>, tensor<f32>)
    %1 = call @expected() : () -> tensor<2x3xf32>
    %2 = stablehlo.broadcast_in_dim %0#0, dims = [] : (tensor<f32>) -> tensor<2x3xf32>
    %3 = stablehlo.broadcast_in_dim %0#2, dims = [] : (tensor<f32>) -> tensor<2x3xf32>
    %4 = stablehlo.clamp %2, %0#1, %3 : tensor<2x3xf32>
    %5 = stablehlo.custom_call @check.eq(%4, %1) : (tensor<2x3xf32>, tensor<2x3xf32>) -> tensor<i1>
    return %5 : tensor<i1>
  }
  func.func private @inputs() -> (tensor<f32>, tensor<2x3xf32>, tensor<f32>) {
    %0 = stablehlo.constant dense<[[-0.0717133358, -3.12108064, 3.0136168], [2.56839752, -3.81903958, 0.721344709]]> : tensor<2x3xf32>
    %1 = stablehlo.constant dense<1.000000e+00> : tensor<f32>
    %2 = stablehlo.constant dense<4.000000e+00> : tensor<f32>
    return %1, %0, %2 : tensor<f32>, tensor<2x3xf32>, tensor<f32>
  }
  func.func private @expected() -> tensor<2x3xf32> {
    %0 = stablehlo.constant dense<[[1.000000e+00, 1.000000e+00, 3.0136168], [2.56839752, 1.000000e+00, 1.000000e+00]]> : tensor<2x3xf32>
    return %0 : tensor<2x3xf32>
  }
}
