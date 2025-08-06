local _, private = ...

local GetItemInfo = (GetItemInfo or C_Item.GetItemInfo)

private.BuyNow = function(itemID, quantity)
    C_AuctionHouse.ConfirmCommoditiesPurchase(itemID, quantity)
end

private.CustomStartCommoditiesPurchase = function(self, itemID, quantity, unitPrice, totalPrice)
    if (quantity > 1) then
        local _, link, _ = GetItemInfo(itemID)
        local data = {
            itemID = itemID,
            count = quantity,
            unitPrice = unitPrice,
            totalPrice = totalPrice,
            link = link,
            useLinkForItemInfo = true,
        };
        StaticPopup_Show('AUCTION_HOUSE_CONFIRM_PURCHASE_AMOUNT', quantity, link, data)

        return
    end

    self.BuyDialog:SetItemID(itemID, quantity, unitPrice, totalPrice);
    self.BuyDialog:Show();
    C_AuctionHouse.StartCommoditiesPurchase(itemID, quantity, unitPrice);
end

if (C_AddOns.IsAddOnLoaded('Blizzard_AuctionHouseUI')) then
    AuctionHouseFrame.StartCommoditiesPurchase = private.CustomStartCommoditiesPurchase
else
    private.frame = CreateFrame('Frame')
    private.frame:HookScript('OnEvent', function(self, event, addon, ...)
        if addon == 'Blizzard_AuctionHouseUI' then
            AuctionHouseFrame.StartCommoditiesPurchase = private.CustomStartCommoditiesPurchase
        end
    end)
    private.frame:RegisterEvent('ADDON_LOADED')
end

StaticPopupDialogs['AUCTION_HOUSE_CONFIRM_PURCHASE_AMOUNT'] = {
    text = 'You selected to buy %s %s, please confirm this.',
    button1 = 'Confirm',
    button2 = 'Cancel',
    --- @param popup StaticPopupTemplate
    OnShow = function(popup, data)
        local button1 = popup.GetButtons and popup:GetButtons()[1] or popup.button1
        local itemFrame = popup.GetItemFrame and popup:GetItemFrame() or popup.itemFrame
        local moneyFrame = popup.MoneyFrame or popup.moneyFrame

        button1:Disable()
        MoneyFrame_Update(moneyFrame, data.totalPrice)
        C_AuctionHouse.StartCommoditiesPurchase(data.itemID, data.count, data.unitPrice);

        itemFrame:ClearAllPoints();
        itemFrame:SetPoint('BOTTOM', popup, 'BOTTOM', -60, 80)
    end,
    OnAccept = function(popup, data)
        private.BuyNow(data.itemID, data.count)
    end,
    EditBoxOnEscapePressed = function(editBox)
        editBox:GetParent():Hide()
    end,
    EditBoxOnEnterPressed = function(editBox)
        --- @type StaticPopupTemplate
        local popup = editBox:GetParent()
        local button1 = popup.GetButtons and popup:GetButtons()[1] or popup.button1
        if button1:IsEnabled() then
            StaticPopup_OnClick(popup, 1)
        end
    end,
    EditBoxOnTextChanged = function(editBox, data)
        --- @type StaticPopupTemplate
        local popup = editBox:GetParent()
        local button1 = popup.GetButtons and popup:GetButtons()[1] or popup.button1
        if (editBox:GetText() == data.count .. '') then
            button1:Enable()
        else
            button1:Disable()
        end
    end,
    hasItemFrame = true,
    hasMoneyFrame = true,
    hasEditBox = true,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}
