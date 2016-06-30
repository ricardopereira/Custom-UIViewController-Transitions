//
//  FlipPresentAnimationController.swift
//  GuessThePet
//
//  Created by Ricardo Pereira on 30/06/16.
//  Copyright © 2016 Razeware LLC. All rights reserved.
//

import UIKit

class FlipPresentAnimationController: NSObject, UIViewControllerAnimatedTransitioning {

    var originFrame = CGRect.zero

    // This is used for percent driven interactive transitions, as well as for container controllers that have companion animations that might need to synchronize with the main animation.
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 2.0
    }

    // This method can only be a nop if the transition is interactive and not a percentDriven interactive transition.
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey),
            let containerView = transitionContext.containerView(),
            let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) else {
                return
        }

        let initialFrame = originFrame
        let finalFrame = transitionContext.finalFrameForViewController(toVC)

        let snapshot = toVC.view.snapshotViewAfterScreenUpdates(true)
        snapshot.frame = initialFrame
        // Match the card corners
        snapshot.layer.cornerRadius = 25
        snapshot.layer.masksToBounds = true

        containerView.addSubview(toVC.view)
        containerView.addSubview(snapshot)
        toVC.view.hidden = true

        AnimationHelper.perspectiveTransformForContainerView(containerView)
        snapshot.layer.transform = AnimationHelper.yRotation(M_PI_2)

        // The duration of your animations to match up with the duration you’ve declared for the whole transition
        UIView.animateKeyframesWithDuration(
            transitionDuration(transitionContext),
            delay: 0,
            options: .CalculationModeCubic,
            animations: {
                // Start by rotating the “from” view halfway around its y-axis to hide it from view.
                UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 1/3, animations: {
                    fromVC.view.layer.transform = AnimationHelper.yRotation(-M_PI_2)
                })

                // Reveal the snapshot using the same technique
                UIView.addKeyframeWithRelativeStartTime(1/3, relativeDuration: 1/3, animations: {
                    snapshot.layer.transform = AnimationHelper.yRotation(0.0)
                })

                // Set the frame of the snapshot to fill the screen
                UIView.addKeyframeWithRelativeStartTime(2/3, relativeDuration: 1/3, animations: {
                    snapshot.frame = finalFrame
                })
            },
            completion: { _ in
                //
                toVC.view.hidden = false
                fromVC.view.layer.transform = AnimationHelper.yRotation(0.0)
                snapshot.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        })
    }

}
