# Tracking assets on chain

---

This repo contains smart contract code for the final project at UPC Barcelona.

We have created a series of smart contracts to follow a vehicle's life cycle since it leaves the factory to the final user - registering all the events in the assets' trajectory.

At the core of our system is an Authorizer contract that defines who can execute which actions. Altough this means the system is centralized (the owner of the contract sets permissions), it allows for smart contract updating, and functionality extension.

The system is designed to be implemented together with a smart card inserted in the vehicle that will sign transactions and identify the vehicle before any event is registered on blockchain.

---

Project contributors:
- [lales12](https://github.com/lales12)
- [Rekard0](https://github.com/Rekard0)
- [csuito](https://github.com/csuito)
