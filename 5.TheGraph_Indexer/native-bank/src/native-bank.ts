import {
  Deposit as DepositEvent,
  Withdrawal as WithdrawalEvent,
} from "../generated/NativeBank/NativeBank";
import { Deposit, Withdrawal, User } from "../generated/schema";
import { BigInt } from "@graphprotocol/graph-ts";

export function handleDeposit(event: DepositEvent): void {
  let user = User.load(event.params.account);
  if (!user) {
    user = new User(event.params.account);
    user.balance = BigInt.zero();
  }
  user.balance += event.params.amount;
  user.save();

  let entity = new Deposit(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  );

  entity.amount = event.params.amount;
  entity.transactionHash = event.transaction.hash;
  entity.user = user.id;

  entity.save();
}

export function handleWithdrawal(event: WithdrawalEvent): void {
  let user = User.load(event.params.account);
  if (!user) {
    user = new User(event.params.account);
    user.balance = BigInt.zero();
  }
  user.balance -= event.params.amount;
  user.save();

  let entity = new Withdrawal(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  );

  entity.amount = event.params.amount;
  entity.transactionHash = event.transaction.hash;
  entity.user = user.id;

  entity.save();
}
