//
//  SwipeInteractionController.swift
//  GuessThePet
//
//  Created by Ricardo Pereira on 30/06/16.
//  Copyright © 2016 Razeware LLC. All rights reserved.
//

import UIKit

enum SwipeInteraction {
    case Left
    case Right
    case Down
}

class SwipeInteractionController: UIPercentDrivenInteractiveTransition {

    var interactionInProgress = false
    private var shouldCompleteTransition = false
    private weak var viewController: UIViewController!

    let swipeInteraction: SwipeInteraction

    init(swipeInteraction: SwipeInteraction) {
        self.swipeInteraction = swipeInteraction
        super.init()
    }

    func wireToViewController(viewController: UIViewController!) {
        self.viewController = viewController
        prepareGestureRecognizerInView(viewController.view)
    }

    private func prepareGestureRecognizerInView(view: UIView) {
        let gesture: UIPanGestureRecognizer
        switch swipeInteraction {
        case .Left:
            gesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleGesture))
            (gesture as! UIScreenEdgePanGestureRecognizer).edges = UIRectEdge.Left
        case .Right:
            gesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleGesture))
            (gesture as! UIScreenEdgePanGestureRecognizer).edges = UIRectEdge.Right
        case .Down:
            gesture = UIPanGestureRecognizer(target: self, action: #selector(handleGesture))
            gesture.minimumNumberOfTouches = 1
            gesture.maximumNumberOfTouches = 1
        }
        view.addGestureRecognizer(gesture)
    }

    func handleGesture(gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
        // Start by declaring local variables to track the progress. You’ll record the translation in the view and calculate the progress. A Swipe of 200 points will lead to 100% completion, so you use this number to measure the transition’s progress.
        let translation = gestureRecognizer.translationInView(gestureRecognizer.view!.superview!)
        print("Translation", translation)

        var progress: CGFloat = 0
        switch swipeInteraction {
        case .Left:
            progress = (translation.x / 200)
            print("Progress", progress)
        case .Right:
            progress = (-translation.x / 200)
            print("Progress", progress)
        case .Down:
            progress = (translation.y / 200)
            print("Progress", progress)
            break
        }

        progress = min(max(progress, 0.0), 1.0)

        switch gestureRecognizer.state {
        case .Began:
            // When the gesture starts, you adjust interactionInProgress accordingly and trigger the dismissal of the view controller.
            interactionInProgress = true
            viewController.dismissViewControllerAnimated(true, completion: nil)

        case .Changed:
            // While the gesture is moving, you continuously call updateInteractiveTransition with the progress amount. This is a method on UIPercentDrivenInteractiveTransition which moves the transition along by the percentage amount you pass in.
            shouldCompleteTransition = progress > 0.5
            updateInteractiveTransition(progress)

        case .Cancelled:
            // If the gesture is cancelled, you update interactionInProgress and roll back the transition.
            interactionInProgress = false
            cancelInteractiveTransition()

        case .Ended:
            // Once the gesture has ended, you use the current progress of the transition to decide whether to cancel it or finish it for the user.
            interactionInProgress = false
            
            if !shouldCompleteTransition {
                cancelInteractiveTransition()
            } else {
                finishInteractiveTransition()
            }
            
        default:
            print("Unsupported")
        }
    }

}
