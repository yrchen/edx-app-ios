//
//  UserProfileViewController.swift
//  edX
//
//  Created by Michael Katz on 9/22/15.
//  Copyright (c) 2015 edX. All rights reserved.
//

import UIKit

public class UserProfileViewController: UIViewController {
    public struct Environment {
        public var networkManager : NetworkManager
        public weak var router : OEXRouter?
        
        public init(networkManager : NetworkManager, router : OEXRouter?) {
            self.networkManager = networkManager
            self.router = router
        }
    }
    
    private let environment : Environment
    
    private let profileFeed: Feed<UserProfile>
    
    private let scrollView = UIScrollView()
    private let margin = 4
    
    private var avatarImage: ProfileImageView!
    private var usernameLabel: UILabel = UILabel()
    private var messageLabel: UILabel = UILabel()
    private var countryLabel: UILabel = UILabel()
    private var languageLabel: UILabel = UILabel()
    private let bioText: UITextView = UITextView()
    
    private var header: ProfileBanner!
    private var spinner = SpinnerView(size: SpinnerView.Size.Large, color: SpinnerView.Color.Primary)
    private let editable:Bool
    
    public init(environment : Environment, feed: Feed<UserProfile>, editable:Bool = true) {
        self.editable = editable
        self.environment = environment
        self.profileFeed = feed
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addListener() {
        profileFeed.output.listen(self, success: { [weak self] profile in
            self?.spinner.removeFromSuperview()
            self?.populateFields(profile)
            }, failure : { [weak self] _ in
                self?.spinner.removeFromSuperview()
                self?.setMessage(Strings.Profile.unableToGet)
                self?.bioText.text = ""
        })
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(scrollView)
        scrollView.backgroundColor = OEXStyles.sharedStyles().primaryBaseColor()
        scrollView.delegate = self
        
        scrollView.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(view)
        }
        
        if editable {
            let editButton = UIBarButtonItem(barButtonSystemItem: .Edit, target: nil, action: nil)
            editButton.oex_setAction() { [weak self] in
                self?.environment.router?.showProfileEditorFromController(self!)
            }
            editButton.accessibilityLabel = Strings.Profile.editAccessibility
            navigationItem.rightBarButtonItem = editButton
        }
    
        navigationController?.navigationBar.tintColor = OEXStyles.sharedStyles().neutralWhite()
        navigationController?.navigationBar.barTintColor = OEXStyles.sharedStyles().primaryBaseColor()
        
        avatarImage = ProfileImageView()
        avatarImage.borderWidth = 3.0
        scrollView.addSubview(avatarImage)

        usernameLabel.setContentHuggingPriority(1000, forAxis: .Vertical)
        scrollView.addSubview(usernameLabel)
        
        messageLabel.hidden = true
        messageLabel.numberOfLines = 0
        messageLabel.setContentHuggingPriority(1000, forAxis: .Vertical)
        scrollView.addSubview(messageLabel)
        
        languageLabel.accessibilityHint = Strings.Profile.languageAccessibilityHint
        languageLabel.setContentHuggingPriority(1000, forAxis: .Vertical)
        scrollView.addSubview(languageLabel)

        countryLabel.accessibilityHint = Strings.Profile.countryAccessibilityHint
        countryLabel.setContentHuggingPriority(1000, forAxis: .Vertical)
        scrollView.addSubview(countryLabel)
        
        bioText.backgroundColor = OEXStyles.sharedStyles().neutralWhiteT()
        bioText.textAlignment = .Natural
        bioText.scrollEnabled = false
        bioText.editable = false
        scrollView.addSubview(bioText)
        
        let whiteSpace = UIView()
        whiteSpace.backgroundColor = bioText.backgroundColor
        scrollView.insertSubview(whiteSpace, belowSubview: bioText)

        avatarImage.snp_makeConstraints { (make) -> Void in
            make.width.equalTo(avatarImage.snp_height)
            make.width.equalTo(166)
            make.centerX.equalTo(scrollView)
            make.top.equalTo(scrollView.snp_topMargin).offset(20)
        }

        usernameLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(avatarImage.snp_bottom).offset(margin)
            make.centerX.equalTo(scrollView)
        }
        
        messageLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(usernameLabel.snp_bottom).offset(margin).priorityHigh()
            make.centerX.equalTo(scrollView)
        }

        languageLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(messageLabel.snp_bottom).offset(margin)
            make.centerX.equalTo(scrollView)
        }
        
        countryLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(languageLabel.snp_bottom).offset(margin)
            make.centerX.equalTo(scrollView)
        }

        bioText.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(countryLabel.snp_bottom).offset(margin + 6).priorityHigh()
            make.bottom.equalTo(scrollView)
            make.leading.equalTo(scrollView)
            make.trailing.equalTo(scrollView)
            make.width.equalTo(scrollView)
        }
        
        whiteSpace.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(bioText)
            make.bottom.greaterThanOrEqualTo(view)
            make.leading.equalTo(bioText)
            make.trailing.equalTo(bioText)
            make.width.equalTo(bioText)
        }


        header = ProfileBanner(frame: CGRectZero)
        header.backgroundColor = scrollView.backgroundColor
        header.hidden = true
        view.addSubview(header)
        
        header.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(scrollView)
            make.leading.equalTo(scrollView)
            make.trailing.equalTo(scrollView)
            make.height.equalTo(56)
        }
        
        addListener()
    }

    private func setMessage(message: String?) {
        if let message = message {
            let messageStyle = OEXTextStyle(weight: .Light, size: .XSmall, color: OEXStyles.sharedStyles().primaryXLightColor())

            messageLabel.hidden = false
            messageLabel.snp_remakeConstraints { (make) -> Void in
                make.top.equalTo(usernameLabel.snp_bottom).offset(margin).priorityHigh()
                make.centerX.equalTo(scrollView)
            }
            countryLabel.hidden = true
            languageLabel.hidden = true
            
            messageLabel.attributedText = messageStyle.attributedStringWithText(message)
        } else {
            messageLabel.hidden = true
            messageLabel.snp_updateConstraints(closure: { (make) -> Void in
                make.height.equalTo(0)
            })
            
            countryLabel.hidden = false
            languageLabel.hidden = false

        }
    }
    
    private func populateFields(profile: UserProfile) {
        let usernameStyle = OEXTextStyle(weight : .Normal, size: .XXLarge, color: OEXStyles.sharedStyles().neutralWhiteT())
        let infoStyle = OEXTextStyle(weight: .Light, size: .XSmall, color: OEXStyles.sharedStyles().primaryXLightColor())
        let bioStyle = OEXStyles.sharedStyles().textAreaBodyStyle

        usernameLabel.attributedText = usernameStyle.attributedStringWithText(profile.username)

        if profile.sharingLimitedProfile {
            
            avatarImage.image = UIImage(named: "avatarPlaceholder")
            
            setMessage(editable ? Strings.Profile.showingLimited : Strings.Profile.learnerHasLimitedProfile(platformName: OEXConfig.sharedConfig().platformName()))

            if (profile.parentalConsent ?? false) && editable {
                let newStyle = OEXMutableTextStyle(textStyle: bioStyle)
                newStyle.alignment = .Center
                newStyle.color = OEXStyles.sharedStyles().neutralBlackT() 
                bioText.attributedText = newStyle.attributedStringWithText(Strings.Profile.under13)
            } else {
                bioText.text = ""
            }
        } else {
            setMessage(nil)

            avatarImage.remoteImage = profile.image(environment.networkManager)

            if let language = profile.language {
                let icon = Icon.Comment.attributedTextWithStyle(infoStyle)
                let langText = infoStyle.attributedStringWithText(language)
                languageLabel.attributedText = NSAttributedString.joinInNaturalLayout([icon, langText])
            }
            if let country = profile.country {
                let icon = Icon.Country.attributedTextWithStyle(infoStyle)
                let countryText = infoStyle.attributedStringWithText(country)
                countryLabel.attributedText = NSAttributedString.joinInNaturalLayout([icon, countryText])
            }
            let bio = profile.bio ?? Strings.Profile.noBio
            bioText.attributedText = bioStyle.attributedStringWithText(bio)
        }
        
        header.showProfile(profile, networkManager: environment.networkManager)
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        profileFeed.refresh()
    }

}

extension UserProfileViewController : UIScrollViewDelegate {
    
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        UIView.animateWithDuration(0.25) {
            self.header.hidden = scrollView.contentOffset.y < CGRectGetMaxY(self.avatarImage.frame)
        }
        
    }
}
