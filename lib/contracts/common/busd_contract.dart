import 'package:automatedefi_web3/contracts/base/erc20_contract.dart';

class BUSDContract extends ERC20Contract {
  BUSDContract.binance({required super.wallet})
      : super(address: "0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56");
}
