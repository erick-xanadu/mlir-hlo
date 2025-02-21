// RUN: stablehlo-opt -inline %s | stablehlo-translate --interpret
// RUN: diff <(stablehlo-translate --serialize --target=current %s | stablehlo-translate --deserialize | stablehlo-opt) <(stablehlo-opt %s)

module @jit_testcase {
  func.func public @main() -> tensor<i1> {
    %0:2 = call @inputs() : () -> (tensor<f32>, tensor<2x3xf32>)
    %1 = call @expected() : () -> tensor<2x3xi1>
    %2 = stablehlo.broadcast_in_dim %0#0, dims = [] : (tensor<f32>) -> tensor<2x3xf32>
    %3 = stablehlo.compare  LT, %2, %0#1,  FLOAT : (tensor<2x3xf32>, tensor<2x3xf32>) -> tensor<2x3xi1>
    %4 = stablehlo.custom_call @check.eq(%3, %1) : (tensor<2x3xi1>, tensor<2x3xi1>) -> tensor<i1>
    return %4 : tensor<i1>
  }
  func.func private @inputs() -> (tensor<f32>, tensor<2x3xf32>) {
    %0 = stablehlo.constant dense<[[4.10293245, 0.864527285, -1.24663937], [2.01758218, 3.02001262, 0.747865558]]> : tensor<2x3xf32>
    %1 = stablehlo.constant dense<0.388011217> : tensor<f32>
    return %1, %0 : tensor<f32>, tensor<2x3xf32>
  }
  func.func private @expected() -> tensor<2x3xi1> {
    %0 = stablehlo.constant dense<[[true, true, false], [true, true, true]]> : tensor<2x3xi1>
    return %0 : tensor<2x3xi1>
  }
}
