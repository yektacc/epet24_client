//import 'package:bloc/bloc.dart';
//import 'package:flutter/material.dart';
//import 'package:store/common/bloc_state_event.dart';
//
//class PackingBloc extends Bloc<PackingEvent, PackingState> {
//  final OrdersRepository _ordersRepository;
//  final int orderId;
//  final int itemId;
//
//  PackingBloc(
//    this._ordersRepository,
//    this.orderId,
//    this.itemId,
//  );
//
//  @override
//  PackingState get initialState => LoadingPacking();
//
//  @override
//  Stream<PackingState> mapEventToState(PackingEvent event) {
//    if (event is GetPackingInfo) {}
//  }
//}
//
//// events and states
//
//@immutable
//abstract class PackingEvent extends BlocEvent {}
//
//@immutable
//abstract class PackingState extends BlocState {
//  PackingState([List props = const []]) : super(props);
//}
//
//class LoadingPacking extends PackingState {
//  LoadingPacking();
//
//  @override
//  String toString() {
//    return "STATE: loading";
//  }
//}
//
//class IsPacked extends PackingState {
//  IsPacked();
//
//  @override
//  String toString() {
//    return "STATE: packed";
//  }
//}
//
//class NotPacked extends PackingState {
//  NotPacked();
//
//  @override
//  String toString() {
//    return "STATE: not packed";
//  }
//}
//
//// EVENTS *******************************
//
//class GetPackingInfo extends PackingEvent {
//  GetPackingInfo();
//
//  @override
//  String toString() {
//    return "get packing";
//  }
//}
