// RUN: stablehlo-opt -inline %s | stablehlo-translate --interpret
// RUN: diff <(stablehlo-translate --serialize --target=current %s | stablehlo-translate --deserialize | stablehlo-opt) <(stablehlo-opt %s)

module @jit_testcase {
  func.func public @main() -> tensor<i1> {
    %0 = stablehlo.constant dense<[[0, 1], [2, 3]]> : tensor<2x2xi32>
    %1:2 = call @inputs() : () -> (tensor<5x6x7xbf16>, tensor<2x7xbf16>)
    %2 = call @expected() : () -> tensor<5x6x7xbf16>
    %3 = "stablehlo.scatter"(%1#0, %0, %1#1) ({
    ^bb0(%arg0: tensor<bf16>, %arg1: tensor<bf16>):
      %5 = stablehlo.multiply %arg0, %arg1 : tensor<bf16>
      stablehlo.return %5 : tensor<bf16>
    }) {scatter_dimension_numbers = #stablehlo.scatter<update_window_dims = [1], inserted_window_dims = [0, 1], scatter_dims_to_operand_dims = [0, 1], index_vector_dim = 1>, unique_indices = true} : (tensor<5x6x7xbf16>, tensor<2x2xi32>, tensor<2x7xbf16>) -> tensor<5x6x7xbf16>
    %4 = stablehlo.custom_call @check.eq(%3, %2) : (tensor<5x6x7xbf16>, tensor<5x6x7xbf16>) -> tensor<i1>
    return %4 : tensor<i1>
  }
  func.func private @inputs() -> (tensor<5x6x7xbf16>, tensor<2x7xbf16>) {
    %0 = stablehlo.constant dense<"0x94C04EBEA5BF28C08EC064BE90BFC4BF34C07AC00DC09E3FC1BF59C01640C2405ABED6BF813F4D408F4046405FBF243EC83FDC3FCF3F3E40F7BF9A3F9640703F8EBFACC00EC0A1407340D3C09B3E0C408AC0333D53402EC018404440B63FC13F4EC08B40014009405BBE00C15FBF504029C0BB3EC73F34409D3D11C025C0F7BD0EC0344095C0B540A83FDB3F54406C3F8840153E1EC0944065BF1C4008405640BD3F86BF09400B40563F9ABF04C01E3F0C4062C0BCC071C0523FC8BFD03C753F56405DC0373F793FAC40FB3F48BF953FD23F1641FEBE9F3F01BF2740904080C0843F8E4025C0ABBFE23FCCBFBF4055C06FBF1740B8BF89BF37BFCF3F4A40DCC082BF43BC8F4035BF4FBF8E40B63EEEBF8D40DDC09D3F13C0E840334097BFD33F12BF94BF4E3E1BBE633F6BBF2FC086BF63402D405340DB3ED6BF27C0823F82BFA5C01E3F2ABEAEC01CBF40408F40994057BEF5BF183FD93FE5BF7FBF8E3F6A404940B8BF433FCE3F3BBF2140FE3E794095400B40BA3FA83FDA3F77404BC09440E2C015BDBC40D9BFA23F5340EF3C0CC0BD40F8C068C0BC40E9BF83C08CBF393F693E04C0"> : tensor<5x6x7xbf16>
    %1 = stablehlo.constant dense<[[-5.875000e+00, 4.199220e-01, -1.022340e-03, 5.187500e+00, -2.218750e+00, 3.234380e+00, -1.429690e+00], [2.734380e+00, 2.500000e+00, 1.804690e+00, -7.539060e-01, -2.265630e+00, -2.160640e-02, -1.468750e+00]]> : tensor<2x7xbf16>
    return %0, %1 : tensor<5x6x7xbf16>, tensor<2x7xbf16>
  }
  func.func private @expected() -> tensor<5x6x7xbf16> {
    %0 = stablehlo.constant dense<"0x94C04EBEA5BF28C08EC064BE90BF104197BF833B37C12FC09CC09B401640C2405ABED6BF813F4D408F4046405FBF243EC83FDC3FCF3F3E40F7BF9A3F9640703F8EBFACC00EC0A1407340D3C09B3E0C408AC0333D53402EC018404440B63FC13F4EC08B40014009405BBE00C15FBF504029C0BB3EC73F34409D3D11C025C0F7BD0EC0344095C0B540A83FDB3F54406C3F8840153E1EC0944065BF1C4008405640BD3F86BF09400B40563F9ABF04C01E3F0C4062C0BCC071C0523FC8BFD03C753F56405DC0373F793FAC40FB3F48BF953FD23FCD419FBF0F40C33EBDC0C7BDBC40843F8E4025C0ABBFE23FCCBFBF4055C06FBF1740B8BF89BF37BFCF3F4A40DCC082BF43BC8F4035BF4FBF8E40B63EEEBF8D40DDC09D3F13C0E840334097BFD33F12BF94BF4E3E1BBE633F6BBF2FC086BF63402D405340DB3ED6BF27C0823F82BFA5C01E3F2ABEAEC01CBF40408F40994057BEF5BF183FD93FE5BF7FBF8E3F6A404940B8BF433FCE3F3BBF2140FE3E794095400B40BA3FA83FDA3F77404BC09440E2C015BDBC40D9BFA23F5340EF3C0CC0BD40F8C068C0BC40E9BF83C08CBF393F693E04C0"> : tensor<5x6x7xbf16>
    return %0 : tensor<5x6x7xbf16>
  }
}

