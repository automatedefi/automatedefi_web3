import 'package:flutter/material.dart';
import 'package:flutter_web3/flutter_web3.dart';

import '../../automatedefi_web3.dart';

class ERC20Contract extends ChangeNotifier {
  ERC20Contract({required this.wallet, required this.address});

  final Web3Wallet wallet;
  final String address;

  late ContractERC20 _contract;

  final Map<String, BigInt> allowances = {};

  String _name = "";
  String get name => _name;

  String _symbol = "";
  String get symbol => _symbol;

  Future<void> initialize() async {
    _contract = ContractERC20(address, wallet.signer!);
    _name = await _contract.name;
    _symbol = await _contract.symbol;
    notifyListeners();
  }

  Future<BigInt> allowance(String spender) async {
    final amount = await _contract.allowance(wallet.currentAddress, spender);
    allowances[address] = amount;
    notifyListeners();
    return allowances[address] ?? BigInt.zero;
  }

  Future<void> approve(String spender, BigInt amount) async {
    await _contract.approve(spender, amount);
    await allowance(spender);
  }
}
