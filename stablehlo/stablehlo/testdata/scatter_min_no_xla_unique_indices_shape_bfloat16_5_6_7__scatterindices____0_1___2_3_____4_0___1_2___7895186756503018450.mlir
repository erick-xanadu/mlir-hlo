// RUN: stablehlo-opt -inline %s | stablehlo-translate --interpret
// RUN: diff <(stablehlo-translate --serialize --target=current %s | stablehlo-translate --deserialize | stablehlo-opt) <(stablehlo-opt %s)

module @jit_testcase {
  func.func public @main() -> tensor<i1> {
    %0 = stablehlo.constant dense<[[[0, 1], [2, 3]], [[4, 0], [1, 2]]]> : tensor<2x2x2xi32>
    %1:2 = call @inputs() : () -> (tensor<5x6x7xbf16>, tensor<5x2x2xbf16>)
    %2 = call @expected() : () -> tensor<5x6x7xbf16>
    %3 = "stablehlo.scatter"(%1#0, %0, %1#1) ({
    ^bb0(%arg0: tensor<bf16>, %arg1: tensor<bf16>):
      %5 = stablehlo.minimum %arg0, %arg1 : tensor<bf16>
      stablehlo.return %5 : tensor<bf16>
    }) {scatter_dimension_numbers = #stablehlo.scatter<update_window_dims = [0], inserted_window_dims = [1, 2], scatter_dims_to_operand_dims = [1, 2], index_vector_dim = 2>, unique_indices = true} : (tensor<5x6x7xbf16>, tensor<2x2x2xi32>, tensor<5x2x2xbf16>) -> tensor<5x6x7xbf16>
    %4 = stablehlo.custom_call @check.eq(%3, %2) : (tensor<5x6x7xbf16>, tensor<5x6x7xbf16>) -> tensor<i1>
    return %4 : tensor<i1>
  }
  func.func private @inputs() -> (tensor<5x6x7xbf16>, tensor<5x2x2xbf16>) {
    %0 = stablehlo.constant dense<"0xFB3EC73FD9BF11C072402640C24010BF95C0CEBF104071403D3FA2BEAFBE52409DC09C40F83D13405EBF6AC01541A4BE8ABE134040BF4CC0F03F743F29C02C40913F8740083F8140F2BDFABFB94082C068BF97C0C43E563E99C0EBBF033FEA3F21C0B2408640CA3F8BBE9C3F3CBFE7BFA63CD9BF6140A3C01BBFBCBF17C016C08940874042408440D2BF2140694028401AC043C077C0F93D81BE943C40BFB5C06140C9BFA03FBDBD48C09CC0CC3F4B40A6C047C0D9C06640913F0AC059BF24C0EEBF5DC00541F03F48C08740B4BFE9402C40A54017C0FFBF6F3EEC4048C017BF9340583FADC00C3F4040354020C04140BE40FBC086C04240A63E06C0BA3F0E40854030BF27BECDC0D93F32C00DC0983F87C0D540A740C640C43F0CBFC9BF693FCA3F943F64C0A4BEEE3E1AC006C0ECBFAF400AC0683F984051BD5AC0A3BF7ABF33BFE73F5CBF55BF6540333A7DC034C00C40A93E05BF6EC0C0BF4EBF0EC0FA3B373DB63E2E4052402D408DBF5BBD18C04240253F93BF2E3FC53F9B3FA13FC1C07E40A63F33409FBE9B40C33FD94054BFB540AF3E1440073E3D40A53FE7BF26402940FE3F"> : tensor<5x6x7xbf16>
    %1 = stablehlo.constant dense<[[[9.335930e-01, -2.437500e+00], [3.500000e+00, -5.039060e-01]], [[-3.265630e+00, 3.925780e-01], [-2.828130e+00, -1.476560e+00]], [[-4.437500e+00, 5.546880e-01], [6.757810e-01, 4.531250e+00]], [[-4.492190e-01, 2.296880e+00], [1.328130e+00, -1.289060e-01]], [[1.960940e+00, 3.484380e+00], [-2.515630e+00, -2.046880e+00]]]> : tensor<5x2x2xbf16>
    return %0, %1 : tensor<5x6x7xbf16>, tensor<5x2x2xbf16>
  }
  func.func private @expected() -> tensor<5x6x7xbf16> {
    %0 = stablehlo.constant dense<"0xFB3E6F3FD9BF11C072402640C24010BF95C0CEBF104071403D3FA2BEAFBE52409DC01CC0F83D13405EBF6AC01541A4BE8ABE134040BF4CC0F03F743F29C02C40913F8740083F8140F2BDFABFB94082C068BF97C0C43E51C099C0EBBF033FEA3F21C0B2408640BDBF8BBE9C3F3CBFE7BFA63CD9BF6140A3C01BBFBCBF17C016C08940874042408440D2BF214035C028401AC043C077C0F93D81BE943C40BFB5C06140C9BFA03FBDBD48C09CC0CC3F4B40A6C047C0D9C06640913F0AC059BF24C0EEBF5DC00541F03F48C00E3FB4BFE9402C40A54017C0FFBF6F3EEC4048C017BF2D3F583FADC00C3F4040354020C04140BE40FBC086C04240A63E06C0BA3FE6BE854030BF27BECDC0D93F32C00DC004BE87C0D540A740C640C43F0CBFC9BF693FCA3F943F64C0A4BEEE3E1AC006C0ECBFAF400AC0683F984051BD5AC0A3BF7ABF33BFE73F5CBF55BF6540333A7DC034C00C40A93E05BF6EC0C0BF4EBF0EC0FA3B373D03C02E4052402D408DBF5BBD18C04240253F93BF2E3FC53F9B3FA13FC1C07E40A63F33409FBE21C0C33FD94054BFB540AF3E1440073E3D40A53FE7BF26402940FE3F"> : tensor<5x6x7xbf16>
    return %0 : tensor<5x6x7xbf16>
  }
}

