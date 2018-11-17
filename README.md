#  Markov: A Reinforcement Learning Framework for Swift

This project is meant to provide a framework for experimenting with Reinforcement Learning concepts using the Swift programming language. It is primarily meant to help me build an understanding of the general reinforcement learning problem, and some of the approaches to solving it.

## Protocols

The framework defines the following protocols in order to lay out the Reinforcement Learning problem in general terms. These protocols employ associated types so that they can be used to model different types of worlds.

* `Distribution`    A basic interface for a probability distribution that lets you define the event type. Useful for modeling problems with random variables. Used to provide fuzzy transitions.

* `MarkovDecisionProcess`   A stochastic process that is modeled as a transition machine, which is composed of a set of states that are connected by actions. The actions are fuzzy, meaning that an agent can choose to perform an action, but the model may cause some other action to actually happen on a transition. So, each action is a random variable with its own distribution. Also associated with each state is a reward, which can be collected each time a state is visited. This model provides more information than an agent would normally receive.

* `Environment` In a true Reinforcement Learning setting the agent does not have insight into the world that is provided by a Markov Decision Process. The Environment protocol presents a narrower interface to agents, one that provides a new state and reward when an agent chooses an action from the current state. Think of sitting down in front of the game Zork for the first time. In that setting you were the agent, and the command line was the environment. 

* `Policy`  A policy represents a plan or strategy that an agent will follow...when in this state, perform this action...in order to maximize long-term gains. Policies are probabilistic. Rather than give a single action, they return the probability of taking an action from the given state.

## Markov Decision Processes

A Markov Decision Process (MDP) is a way of modeling a transition system with the Markov property. Simply put, the Markov property states that it is possible to determine the next state of a system given the current state of the system. In other words, it does not matter what events occurred up until the current state; everything that is important about the system is captured in the current state. Systems that exibit the Markov property can be analyzed using techniques like *policy iteration* and *value iteration*.

When presented with an MDP we have all the information necessary to determine an *optimal policy*, which can then be used to determine the *optimal value function*.

### Formal Definition

An MDP consists of the following:

* S - the set of states that the system can be in.
* A(s) - the set of actions that can be taken from a given state.
* T(s, a) -> (s', r) - the transition function, which, given a state and an action, transitions to the next state, and yields a reward.

It is worth noting that the transition function T can be non-deterministic. When an action is selected for a given state, one of several (or many!) possible transitions may actually occur, according to a distribution of transitions.

### States

The notion of a state is quite generic in this framework. You can define any type that conforms to the `Hashable` protocol. Your choice of data representation is very important, since the state representation is what determines whether your transition system will have the Markov property. Strive to provide as compact a representation as possible. Also, states should use value semantics.

### Actions

An action represents a choice made by the agent. Actions are best represented with Swift `enum` types. Not only will this keep all of your actions together for a particular MDP, you can also use features like associated data, to allow an agent to pass data in an action (e.g. placing a bet in a game of chance.) Like states, actions must conform to the `Hashable` protocol.

### Rewards

Rewards are numerical amounts which are given each time a transition occurs. In this framework they are of type `Double`, and can be positive, negative, or zero. No special care is taken to prevent infinite rewards, but this should be avoided, since this will destroy any hopes of convergence.

### Value Functions

A *value function* is a mapping, either from state to rewards, or state-action pairs to rewards. Value functions are defined for a given policy, because it is necessary to know what actions will be taken, either from the given state, or after taking the given action from the given state, depending on whether we have a state-value function or an action-value function.

### Transitions

The `Transition` type pairs a state with a reward. It is important to realize that a transition represents an edge label in the graph representation of a transition system. As mentioned before, the transition function in an MDP is actually stochastic. This can be modelled by defining a `Distribution` of `Transition` objects for each action that can be selected in a state. 
