// RUN: stablehlo-opt -inline %s | stablehlo-translate --interpret
// RUN: diff <(stablehlo-translate --serialize --target=current %s | stablehlo-translate --deserialize | stablehlo-opt) <(stablehlo-opt %s)

module @jit_testcase {
  func.func public @main() -> tensor<i1> {
    %0:4 = call @inputs() : () -> (tensor<2x3xi32>, tensor<2x3xui16>, tensor<2x3xui16>, tensor<2x3xui16>)
    %1 = call @expected() : () -> tensor<2x3xui16>
    %2 = stablehlo.constant dense<1> : tensor<i32>
    %3 = stablehlo.broadcast_in_dim %2, dims = [] : (tensor<i32>) -> tensor<2x3xi32>
    %4 = stablehlo.compare  LT, %0#0, %3,  SIGNED : (tensor<2x3xi32>, tensor<2x3xi32>) -> tensor<2x3xi1>
    %5 = stablehlo.constant dense<2> : tensor<i32>
    %6 = stablehlo.broadcast_in_dim %5, dims = [] : (tensor<i32>) -> tensor<2x3xi32>
    %7 = stablehlo.compare  LT, %0#0, %6,  SIGNED : (tensor<2x3xi32>, tensor<2x3xi32>) -> tensor<2x3xi1>
    %8 = stablehlo.select %7, %0#2, %0#3 : tensor<2x3xi1>, tensor<2x3xui16>
    %9 = stablehlo.select %4, %0#1, %8 : tensor<2x3xi1>, tensor<2x3xui16>
    %10 = stablehlo.custom_call @check.eq(%9, %1) : (tensor<2x3xui16>, tensor<2x3xui16>) -> tensor<i1>
    return %10 : tensor<i1>
  }
  func.func private @inputs() -> (tensor<2x3xi32>, tensor<2x3xui16>, tensor<2x3xui16>, tensor<2x3xui16>) {
    %0 = stablehlo.constant dense<[[1, 2, 2], [1, 1, 2]]> : tensor<2x3xi32>
    %1 = stablehlo.constant dense<[[2, 0, 4], [5, 0, 0]]> : tensor<2x3xui16>
    %2 = stablehlo.constant dense<[[5, 1, 0], [1, 2, 0]]> : tensor<2x3xui16>
    %3 = stablehlo.constant dense<[[3, 0, 0], [1, 0, 1]]> : tensor<2x3xui16>
    return %0, %1, %2, %3 : tensor<2x3xi32>, tensor<2x3xui16>, tensor<2x3xui16>, tensor<2x3xui16>
  }
  func.func private @expected() -> tensor<2x3xui16> {
    %0 = stablehlo.constant dense<[[5, 0, 0], [1, 2, 1]]> : tensor<2x3xui16>
    return %0 : tensor<2x3xui16>
  }
}
