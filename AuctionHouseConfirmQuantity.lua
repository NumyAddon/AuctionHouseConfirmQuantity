EventUtil.ContinueOnAddOnLoaded('Blizzard_AuctionHouseUI', function()
    local function buyNow(itemID, quantity)
        C_AuctionHouse.ConfirmCommoditiesPurchase(itemID, quantity)
    end

    local originalStartCommoditiesPurchase = AuctionHouseFrame.StartCommoditiesPurchase
    AuctionHouseFrame.StartCommoditiesPurchase = function(self, itemID, quantity, unitPrice, totalPrice)
        if quantity == 1 then
            originalStartCommoditiesPurchase(self, itemID, quantity, unitPrice, totalPrice)
            return
        end

        local _, link, _ = C_Item.GetItemInfo(itemID)
        local data = {
            itemID = itemID,
            count = quantity,
            unitPrice = unitPrice,
            totalPrice = totalPrice,
            link = link,
            useLinkForItemInfo = true,
        };
        StaticPopup_Show('AUCTION_HOUSE_CONFIRM_PURCHASE_AMOUNT', quantity, link, data)
    end

    StaticPopupDialogs['AUCTION_HOUSE_CONFIRM_PURCHASE_AMOUNT'] = {
        text = 'You selected to buy %d %s, please confirm this.',
        button1 = 'Confirm',
        button2 = 'Cancel',
        --- @param popup StaticPopupTemplate
        OnShow = function(popup, data)
            --- @type StaticPopupButtonTemplate
            local button1 = popup.GetButton1 and popup:GetButton1() or popup.button1
            --- @type StaticPopupTemplate_ItemFrame
            local itemFrame = popup.GetItemFrame and popup:GetItemFrame() or popup.itemFrame
            --- @type StaticPopupTemplate_MoneyFrame
            local moneyFrame = popup.MoneyFrame or popup.moneyFrame

            button1:Disable()
            MoneyFrame_Update(moneyFrame, data.totalPrice)
            C_AuctionHouse.StartCommoditiesPurchase(data.itemID, data.count, data.unitPrice);

            itemFrame:ClearAllPoints();
            itemFrame:SetPoint('BOTTOM', popup, 'BOTTOM', -60, 80)
        end,
        OnAccept = function(popup, data)
            buyNow(data.itemID, data.count)
        end,
        EditBoxOnEscapePressed = function(editBox)
            editBox:GetParent():Hide()
        end,
        EditBoxOnEnterPressed = function(editBox)
            --- @type StaticPopupTemplate
            local popup = editBox:GetParent()
            --- @type StaticPopupButtonTemplate
            local button1 = popup.GetButton1 and popup:GetButton1() or popup.button1
            if button1:IsEnabled() then
                StaticPopup_OnClick(popup, 1)
            end
        end,
        EditBoxOnTextChanged = function(editBox, data)
            --- @type StaticPopupTemplate
            local popup = editBox:GetParent()
            --- @type StaticPopupButtonTemplate
            local button1 = popup.GetButton1 and popup:GetButton1() or popup.button1
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
end)
