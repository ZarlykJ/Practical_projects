// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';

import 'package:eco_market/features/cart/domain/entities/entity.dart';

abstract class CartScreenState extends Equatable {
  const CartScreenState();
  @override
  List<Object?> get props => [];
}

class CartScreenInitial extends CartScreenState {}

class CartScreenLoading extends CartScreenState {}

class CartScreenLoaded extends CartScreenState {
  final List<OrderEntity> orders;
  const CartScreenLoaded({
    required this.orders,
  });
}

class CartScreenFailure extends CartScreenState {
  final Object? exception;

  const CartScreenFailure(this.exception);
}
