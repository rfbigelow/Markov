#  Markov: A Reinforcement Learning Framework for Swift

This project is meant to provide a framework for experimenting with Reinforcement Learning concepts using the Swift programming language. It is primarily meant to help me build an understanding of the general reinforcement learning problem, and some of the approaches to solving it.

## Protocols

The framework defines the following protocols in order to lay out the Reinforcement Learning problem in general terms. These protocols employ associated types so that they can be used to model different types of worlds.

* Distribution: A basic interface for a probability distribution that lets you define the event type. Useful for modeling problems with random variables. Used to provide fuzzy transitions.

* MarkovDecisionProcess: A stochastic process that is modeled as a transition machine, which is composed of a set of states that are connected by actions. The actions are fuzzy, meaning that an agent can choose to perform an action, but the model may cause some other action to actually happen on a transition. So, each action is a random variable with its own distribution. Also associated with each state is a reward, which can be collected each time a state is visited. This model provides more information than an agent would normally receive.

* Environment: In a true Reinforcement Learning setting the agent does not have insight into the world that is provided by a Markov Decision Process. The Environment protocol presents a narrower interface to agents, one that provides a new state and reward when an agent chooses an action from the current state. Think of sitting down in front of the game Zork for the first time. In that setting you were the agent, and the command line was the environment. 

* Policy: A policy represents a plan or strategy that an agent will follow...when in this state, perform this action...in order to maximize long-term gains. Policies are probabilistic. Rather than give a single action, they return the probability of taking an action from the given state.

 
