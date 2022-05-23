import 'package:flutter/material.dart';
import 'package:flutter_web3/flutter_web3.dart';

import '../../automatedefi_web3.dart';

class ERC20Contract extends ChangeNotifier {
  ERC20Contract({required this.wallet, required this.address});

  final Web3Wallet wallet;
  final String address;

  late ContractERC20 _contract;

  final Map<String, BigInt> _allowances = {};

  String _name = "";
  String get name => _name;

  String _symbol = "";
  String get symbol => _symbol;

  Future<void> initialize() async {
    _contract = ContractERC20(address, wallet.signer!);
    _name = await _contract.name;
    _symbol = await _contract.symbol;
    _contract.onApproval((owner, spender, value, event) {
      if (owner.toLowerCase() != wallet.currentAddress.toLowerCase()) {
        return;
      }
      _allowances[spender] = value;
      notifyListeners();
    });
    notifyListeners();
  }

  BigInt allowance(String spender) {
    _contract.allowance(wallet.currentAddress, spender).then((amount) {
      _allowances[spender] = amount;
      notifyListeners();
    });
    return _allowances[address] ?? BigInt.zero;
  }

  void approve(String spender, BigInt amount) {
    _contract.approve(spender, amount);
  }
}
