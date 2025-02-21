// RUN: stablehlo-opt -inline %s | stablehlo-translate --interpret
// RUN: diff <(stablehlo-translate --serialize --target=current %s | stablehlo-translate --deserialize | stablehlo-opt) <(stablehlo-opt %s)

module @jit_testcase {
  func.func public @main() -> tensor<i1> {
    %0 = stablehlo.constant dense<32> : tensor<1xi32>
    %1:2 = call @inputs() : () -> (tensor<1x50x3xi8>, tensor<1x3xi8>)
    %2 = call @expected() : () -> tensor<1x50x3xi8>
    %3 = "stablehlo.scatter"(%1#0, %0, %1#1) ({
    ^bb0(%arg0: tensor<i8>, %arg1: tensor<i8>):
      %5 = stablehlo.minimum %arg0, %arg1 : tensor<i8>
      stablehlo.return %5 : tensor<i8>
    }) {scatter_dimension_numbers = #stablehlo.scatter<update_window_dims = [0, 1], inserted_window_dims = [1], scatter_dims_to_operand_dims = [1]>, unique_indices = true} : (tensor<1x50x3xi8>, tensor<1xi32>, tensor<1x3xi8>) -> tensor<1x50x3xi8>
    %4 = stablehlo.custom_call @check.eq(%3, %2) : (tensor<1x50x3xi8>, tensor<1x50x3xi8>) -> tensor<i1>
    return %4 : tensor<i1>
  }
  func.func private @inputs() -> (tensor<1x50x3xi8>, tensor<1x3xi8>) {
    %0 = stablehlo.constant dense<"0xFC000001000202FF0302FDFDFF00FFFF0003FCFEFEFEFC04FE000000020300FF050705000200FE03FC0203000605FD00FA0000FFFFFC0100FFFF00FCFE03FEFB0004FEFE0001FC040000FF0000FEFE00FE06F901020203FFFE000000020201FE01FBFD01FF0000020300FEFCFE00FF0602F900FE03F9FFFF060101FF000000FF04FFFEF8FFFE00FF0300FA00FD0202FE0000000002FB"> : tensor<1x50x3xi8>
    %1 = stablehlo.constant dense<[[0, 1, -2]]> : tensor<1x3xi8>
    return %0, %1 : tensor<1x50x3xi8>, tensor<1x3xi8>
  }
  func.func private @expected() -> tensor<1x50x3xi8> {
    %0 = stablehlo.constant dense<"0xFC000001000202FF0302FDFDFF00FFFF0003FCFEFEFEFC04FE000000020300FF050705000200FE03FC0203000605FD00FA0000FFFFFC0100FFFF00FCFE03FEFB0004FEFE0001FC040000FF0000FEFE00FE06F901020203FFFE000000020201FE00FBFD01FF0000020300FEFCFE00FF0602F900FE03F9FFFF060101FF000000FF04FFFEF8FFFE00FF0300FA00FD0202FE0000000002FB"> : tensor<1x50x3xi8>
    return %0 : tensor<1x50x3xi8>
  }
}

