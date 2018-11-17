#  Markov: A Reinforcement Learning Framework for Swift

This project is meant to provide a framework for experimenting with Reinforcement Learning concepts using the Swift programming language. It is primarily meant to help me build an understanding of the general reinforcement learning problem, and some of the approaches to solving it.

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

## Reinforcement Learning and the Environment

While the Markov Decision Process model provides all of the informatino necessary to compute an optimal policy, this is not usually available to an agent. Instead, the agent is typically confronted with an environment, where it must learn from experience what "rewards" await it (remember, a reward can be negative as well as positive.) In this framework, the *agent-environment interface* is provided by the `Environment` protocol. If you already have an MDP, then you can easily hide it behind an `Environment` interface with the `MdpEnvironment` class. All that is required besides the actual MDP is the initial state to place the environment in.

## Protocols

The framework defines the following protocols in order to lay out the Reinforcement Learning problem in general terms. These protocols employ associated types so that they can be used to model different types of worlds.

* `Distribution`    A basic interface for a probability distribution that lets you define the event type. Useful for modeling problems with random variables. Used to provide fuzzy transitions.

* `MarkovDecisionProcess`   A stochastic process that is modeled as a transition machine, which is composed of a set of states that are connected by actions. The actions are fuzzy, meaning that an agent can choose to perform an action, but the model may cause some other action to actually happen on a transition. So, each action is a random variable with its own distribution. Also associated with each state is a reward, which can be collected each time a state is visited. This model provides more information than an agent would normally receive.

* `Environment` In a true Reinforcement Learning setting the agent does not have insight into the world that is provided by a Markov Decision Process. The Environment protocol presents a narrower interface to agents, one that provides a new state and reward when an agent chooses an action from the current state. Think of sitting down in front of the game Zork for the first time. In that setting you were the agent, and the command line was the environment. 

* `Policy`  A policy represents a plan or strategy that an agent will follow...when in this state, perform this action...in order to maximize long-term gains. Policies are probabilistic. Rather than give a single action, they return the probability of taking an action from the given state.

## Structs

### Distributions

* `WeightedDistribution`    Represents a simple distribution of weighted events. The weights, which are of type `Double`, must sum to `1.0`.

* `BinDistribution`  Represents a distribution of events that all have an equal chance of occurring (think of a bin full of balls.) Very convenient, and very space-inefficient, since even identical events are represented by separate values.

* `DistributionEstimator`   Represents a sample-based estimate of a distribution by counting events as they occur.

### Policies

* `RandomSelectPolicy`  A policy that randomly selects from all available actions, with equal probability.

* `StochasticPolicy`    A policy that randomly selects from one of a distribution of equally probable actions. This differs from the `RandomSelectPolicy` in that the distributions are configurable, and it does not require a `MarkovDecisionProcess` to provide the available actions. This is used by the `PolicyImprover` to track more than one "best" action for any given situation, which allows for more exploration of the state space when using the policy.

* `EpsilonGreedyPolicy` A policy that chooses the best possible action for a given state most of the time, but occassionally (with probability `epsilon`) selects a random action. This is used to tune the exploit/explore qualities of a reinforcement learning algorithm. If `epsilon` is `0.0` then this will act as a greedy policy.

## Classes

### MDPs

* `TableDrivenMDP`  Provides a tabular implementation of the `MarkovDecisionProcess` protocol. Tabular representations provide a common means of defining MDPs, but they require space for all of the possible states, along with all of the transitions between those states. Great for smaller problems.

* `GridWorld`   A tabular implementation of the Grid World MDP from Sutton and Barto. This implementation sets up the grid with walls around the perimeter, each of which has a reward value of -1.0. The grid can then be customized by adding two types of features. The first feature is a *nexus*, which is a grid square that, once entered, leads to a target grid square no matter which direction is chosen by the agent. The reward for this can be specified. The second feature is a *vortex*, which is a grid square from which there is no escape. The reward can also be specified for this feature. If you want to create a GridWorld with an end goal, you can do so by adding a *vortex* with a positive reward.

### Dynamic Programming

* `PolicyEvaluator` This class implements *value iteration* in order to determine the value function for a given policy.

* `PolicyImprover`  This class implements *policy iteration* in order to improve a given policy. It also implements *generalize policy iteration* or GPI in order to find an optimal policy.

### Q-Learning

* `QLearner`    Implements *q learning*, which is an off-policy reinforcement learning technique.

## Functions

### Dynamic Programming

* `getStateValue`   A *state value function* (i.e. V_pi(s)) used for policy evaluation.

* `getActionValue`  An *action value function* (i.e. Q_pi(s, a)) used for policy improvement.
