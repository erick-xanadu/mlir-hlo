// RUN-DISABLED: stablehlo-opt -inline %s | stablehlo-translate --interpret
// RUN: diff <(stablehlo-translate --serialize --target=current %s | stablehlo-translate --deserialize | stablehlo-opt) <(stablehlo-opt %s)

module @jit_testcase {
  func.func public @main() -> tensor<i1> {
    %0 = call @inputs() : () -> tensor<2x3xi16>
    %1 = call @expected() : () -> tensor<2x3xbf16>
    %2 = stablehlo.bitcast_convert %0 : (tensor<2x3xi16>) -> tensor<2x3xbf16>
    %3 = stablehlo.custom_call @check.eq(%2, %1) : (tensor<2x3xbf16>, tensor<2x3xbf16>) -> tensor<i1>
    return %3 : tensor<i1>
  }
  func.func private @inputs() -> tensor<2x3xi16> {
    %0 = stablehlo.constant dense<[[0, -7, 4], [1, -4, -3]]> : tensor<2x3xi16>
    return %0 : tensor<2x3xi16>
  }
  func.func private @expected() -> tensor<2x3xbf16> {
    %0 = stablehlo.constant dense<[[0.000000e+00, 0xFFF9, 3.673420e-40], [9.183550e-41, 0xFFFC, 0xFFFD]]> : tensor<2x3xbf16>
    return %0 : tensor<2x3xbf16>
  }
}
