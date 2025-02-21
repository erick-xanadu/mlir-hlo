// RUN: stablehlo-opt -inline %s | stablehlo-translate --interpret
// RUN: diff <(stablehlo-translate --serialize --target=current %s | stablehlo-translate --deserialize | stablehlo-opt) <(stablehlo-opt %s)

module @jit_testcase {
  func.func public @main() -> tensor<i1> {
    %0 = stablehlo.constant dense<1> : tensor<2x1xi32>
    %1:2 = call @inputs() : () -> (tensor<3x5x4xui16>, tensor<3x2x4xui16>)
    %2 = call @expected() : () -> tensor<3x5x4xui16>
    %3 = "stablehlo.scatter"(%1#0, %0, %1#1) ({
    ^bb0(%arg0: tensor<ui16>, %arg1: tensor<ui16>):
      %5 = stablehlo.maximum %arg0, %arg1 : tensor<ui16>
      stablehlo.return %5 : tensor<ui16>
    }) {scatter_dimension_numbers = #stablehlo.scatter<update_window_dims = [0, 2], inserted_window_dims = [1], scatter_dims_to_operand_dims = [1], index_vector_dim = 1>} : (tensor<3x5x4xui16>, tensor<2x1xi32>, tensor<3x2x4xui16>) -> tensor<3x5x4xui16>
    %4 = stablehlo.custom_call @check.eq(%3, %2) : (tensor<3x5x4xui16>, tensor<3x5x4xui16>) -> tensor<i1>
    return %4 : tensor<i1>
  }
  func.func private @inputs() -> (tensor<3x5x4xui16>, tensor<3x2x4xui16>) {
    %0 = stablehlo.constant dense<[[[1, 1, 3, 1], [4, 3, 1, 1], [5, 4, 2, 0], [2, 1, 1, 3], [0, 4, 2, 1]], [[2, 5, 0, 1], [2, 1, 1, 3], [6, 1, 0, 4], [2, 0, 1, 5], [0, 2, 0, 2]], [[2, 1, 3, 1], [5, 3, 0, 4], [0, 7, 0, 4], [5, 1, 3, 1], [2, 5, 0, 1]]]> : tensor<3x5x4xui16>
    %1 = stablehlo.constant dense<[[[0, 0, 2, 2], [1, 3, 0, 3]], [[2, 0, 1, 2], [0, 0, 0, 2]], [[1, 0, 2, 0], [0, 1, 1, 0]]]> : tensor<3x2x4xui16>
    return %0, %1 : tensor<3x5x4xui16>, tensor<3x2x4xui16>
  }
  func.func private @expected() -> tensor<3x5x4xui16> {
    %0 = stablehlo.constant dense<[[[1, 1, 3, 1], [4, 3, 2, 3], [5, 4, 2, 0], [2, 1, 1, 3], [0, 4, 2, 1]], [[2, 5, 0, 1], [2, 1, 1, 3], [6, 1, 0, 4], [2, 0, 1, 5], [0, 2, 0, 2]], [[2, 1, 3, 1], [5, 3, 2, 4], [0, 7, 0, 4], [5, 1, 3, 1], [2, 5, 0, 1]]]> : tensor<3x5x4xui16>
    return %0 : tensor<3x5x4xui16>
  }
}

