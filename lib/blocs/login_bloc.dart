import 'dart:async';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gerente_loja/validators/login_validators.dart';
import 'package:rxdart/rxdart.dart';

enum LoginState { idle, loading, success, fail }

class LoginBloc extends BlocBase with LoginValidators {
  final _emailController = BehaviorSubject<String>();
  final _passwordController = BehaviorSubject<String>();
  final _stateController = BehaviorSubject<LoginState>();

  Stream<String> get outEmail =>
      _emailController.stream.transform(validateEmail);

  Stream<String> get outPassword =>
      _passwordController.stream.transform(validatePassword);

  Stream<LoginState> get outState => _stateController.stream;

  Stream<bool> get outSubmitValid =>
      Rx.combineLatest2(outEmail, outPassword, (a, b) => true);

  Function(String) get changeEmail => _emailController.sink.add;

  Function(String) get changePassword => _passwordController.sink.add;

  StreamSubscription? _streamSubscription;

  LoginBloc() {
    _streamSubscription = FirebaseAuth.instance.authStateChanges().listen(
      (user) async {
        if (user != null) {
          if (await verifyPrivileges(user)) {
            _stateController.add(LoginState.success);
          } else {
            FirebaseAuth.instance.signOut();
            _stateController.add(LoginState.fail);
          }
        } else {
          _stateController.add(LoginState.idle);
        }
      },
    );
  }

  void submit() {
    final email = _emailController.value;
    final password = _passwordController.value;

    _stateController.add(LoginState.loading);

    FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password)
        .catchError(
      (e) {
        _stateController.add(LoginState.fail);
      },
    );
  }

  Future<bool> verifyPrivileges(User user) async {
    return await FirebaseFirestore.instance
        .collection("admins")
        .doc(user.uid)
        .get()
        .then(
      (doc) {
        if (doc.data() != null) {
          return true;
        } else {
          return false;
        }
      },
    ).catchError(
      (e) {
        return false;
      },
    );
  }

  @override
  void dispose() {
    super.dispose();

    _emailController.close();
    _passwordController.close();
    _stateController.close();
    _streamSubscription!.cancel();
  }
}
