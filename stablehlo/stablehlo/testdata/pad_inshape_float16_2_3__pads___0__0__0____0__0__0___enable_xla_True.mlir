// RUN: stablehlo-opt -inline %s | stablehlo-translate --interpret
// RUN: diff <(stablehlo-translate --serialize --target=current %s | stablehlo-translate --deserialize | stablehlo-opt) <(stablehlo-opt %s)

module @jit_testcase {
  func.func public @main() -> tensor<i1> {
    %0:2 = call @inputs() : () -> (tensor<2x3xf16>, tensor<f16>)
    %1 = call @expected() : () -> tensor<2x3xf16>
    %2 = stablehlo.pad %0#0, %0#1, low = [0, 0], high = [0, 0], interior = [0, 0] : (tensor<2x3xf16>, tensor<f16>) -> tensor<2x3xf16>
    %3 = stablehlo.custom_call @check.eq(%2, %1) : (tensor<2x3xf16>, tensor<2x3xf16>) -> tensor<i1>
    return %3 : tensor<i1>
  }
  func.func private @inputs() -> (tensor<2x3xf16>, tensor<f16>) {
    %0 = stablehlo.constant dense<[[1.018520e-03, 1.488920e-04, 2.366300e-04], [1.965760e-04, 1.418110e-03, 8.430480e-04]]> : tensor<2x3xf16>
    %1 = stablehlo.constant dense<0.000000e+00> : tensor<f16>
    return %0, %1 : tensor<2x3xf16>, tensor<f16>
  }
  func.func private @expected() -> tensor<2x3xf16> {
    %0 = stablehlo.constant dense<[[1.018520e-03, 1.488920e-04, 2.366300e-04], [1.965760e-04, 1.418110e-03, 8.430480e-04]]> : tensor<2x3xf16>
    return %0 : tensor<2x3xf16>
  }
}
