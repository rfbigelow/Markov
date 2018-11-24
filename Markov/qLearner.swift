//
//  qLearner.swift
//  Markov
//
//  Created by Robert Bigelow on 11/16/18.
//  Copyright © 2018 Robert Bigelow. All rights reserved.
//

/// A reinforcement learner that uses Q-learning to learn an approximation to the optimal action-value function q.
class QLearner<T: Environment, TStepFunction: StepFunction> where T.State == TStepFunction.State, T.Action == TStepFunction.Action {
    private struct Step {
        let from: T.State
        let to: T.State
        let action: T.Action
        let reward: Reward
    }
    
    private var environment: T
    private let discount: Double
    private let stepFunc: TStepFunction
    
    /// The estimated values for the q function
    var estimates: Dictionary<T.State, Dictionary<T.Action, Reward>>
    
    /// Initializes a q-learner with the given environment, discount value, and step function.
    init(environment: T, discount: Double, stepFunc: TStepFunction) {
        self.environment = environment
        self.discount = discount
        self.stepFunc = stepFunc
        self.estimates = Dictionary()
    }
    
    /// Updates the estimated values by using the Q-learning algorithm.
    func learn(withPolicy policy: EpsilonGreedyPolicy<T.State, T.Action>,
               fromState initialState: T.State,
               forSteps steps: Int) -> Int {
        environment.reset(initialState: initialState)
        var stepsTaken = 0
        for _ in 0..<steps {
            if let action = policy.getAction(forState: environment.currentState) {
                let state = environment.currentState
                let (nextState, reward) = environment.select(action: action)
                let current = getEstimate(forState: state, action: action)
                let nextActions = environment.getActions(forState: nextState)
                let next = nextActions?.map({ getEstimate(forState: nextState, action: $0) }).max() ?? 0.0
                let stepSize = stepFunc.stepSize(state, action)
                let backup = current + stepSize * (reward + discount * next - current)
                setEstimate(forState: state, action: action, toValue: backup)
            }
            else {
                break
            }
            stepsTaken += 1
        }
        return stepsTaken
    }
    
    func learnBackwards(withPolicy policy: EpsilonGreedyPolicy<T.State, T.Action>,
    fromState initialState: T.State,
    forSteps steps: Int) -> Int {
        environment.reset(initialState: initialState)
        var stepsTaken = 0
        var history = [Step]()
        for _ in 0..<steps {
            if let action = policy.getAction(forState: environment.currentState) {
                let state = environment.currentState
                let (nextState, reward) = environment.select(action: action)
                history.append(Step(from: state, to: nextState, action: action, reward: reward))
            }
            else {
                break
            }
            stepsTaken += 1
        }
        
        for step in history.reversed() {
            let current = getEstimate(forState: step.from, action: step.action)
            let nextActions = environment.getActions(forState: step.to)
            let next = nextActions?.map({ getEstimate(forState: step.to, action: $0) }).max() ?? 0.0
            let stepSize = stepFunc.stepSize(step.from, step.action)
            let backup = current + stepSize * (step.reward + discount * next - current)
            setEstimate(forState: step.from, action: step.action, toValue: backup)
        }
        
        return stepsTaken
    }
    
    /// Gets the current estimate for the given state/action pair.
    func getEstimate(forState state: T.State, action: T.Action) -> Reward {
        if let actionValues = estimates[state], let estimate = actionValues[action] {
            return estimate
        }
        return 0.0
    }
    
    /// Sets the current estimate for the given state/action pair to the given value.
    private func setEstimate(forState state: T.State, action: T.Action, toValue val: Reward) {
        var actionValues = estimates[state] ?? Dictionary()
        actionValues[action] = val
        estimates[state] = actionValues
    }
}
