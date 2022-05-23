import 'package:flutter/material.dart';
import 'package:flutter_web3/flutter_web3.dart';

class Web3Wallet extends ChangeNotifier {
  Web3Wallet(
      {required this.operatingChain, required this.rpc, required this.network});

  Web3Provider? web3;

  final int operatingChain;
  final String rpc;
  final String network;

  String _currentAddress = "";
  String get currentAddress => _currentAddress;
  int _currentChain = -1;
  int get currentChain => _currentChain;

  bool get injectedWeb3Available => Ethereum.isSupported;

  bool get isInOperatingChain => operatingChain == currentChain;

  bool get isConnected => web3 != null && currentAddress.isNotEmpty;

  Signer? get signer => web3?.getSigner();

  void connect(bool useWalletConnect) async {
    if (useWalletConnect) {
      try {
        web3 = Web3Provider.fromWalletConnect(_createWalletConnectProvider());
      } catch (error) {
        debugPrint(error.toString());
      }
    } else {
      _connectEthereum();
    }
  }

  void _onConnect(String account, int chain) {
    _currentAddress = account;
    _currentChain = chain;
    notifyListeners();
  }

  void disconnect() async {
    web3 = null;
    _currentAddress = "";
    _currentChain = -1;
    notifyListeners();
  }

  WalletConnectProvider _createWalletConnectProvider() {
    final wcProvider = WalletConnectProvider.fromRpc(
      {
        operatingChain: rpc,
      },
      chainId: operatingChain,
      network: network,
    );
    wcProvider.onConnect(() {
      _onConnect(wcProvider.accounts.first, int.parse(wcProvider.chainId));
    });
    wcProvider.onChainChanged((chainId) {
      _onConnect(wcProvider.accounts.first, int.parse(wcProvider.chainId));
    });
    wcProvider.onDisconnect((code, reason) {
      disconnect();
    });
    _connectWCwithoutError(wcProvider);
    return wcProvider;
  }

  void _connectWCwithoutError(WalletConnectProvider wcp) async {
    try {
      await wcp.connect();
    } catch (_) {
      //prevents error from stack trace
    }
  }

  void _connectEthereum() async {
    if (ethereum == null) {
      return;
    }
    ethereum!.onConnect((info) async {
      final accs = await ethereum!.getAccounts();
      _onConnect(accs.first, int.parse(info.chainId));
    });
    ethereum!.onChainChanged((chainId) async {
      final accs = await ethereum!.getAccounts();
      _onConnect(accs.first, chainId);
    });
    ethereum!.onDisconnect((_) {
      disconnect();
    });
    final accs = await ethereum!.requestAccount();
    if (accs.isNotEmpty) {
      final chainId = await ethereum!.getChainId();
      web3 = Web3Provider.fromEthereum(ethereum!);
      _onConnect(accs.first, chainId);
    }
  }
}
