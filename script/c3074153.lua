--銀河間流星

local s,id=GetID()
function s.initial_effect(c)
    --Destroy Monster
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetHintTiming(0,TIMING_END_PHASE)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.moncon)
    e1:SetCost(s.descost)
    e1:SetTarget(s.montg)
    e1:SetOperation(s.desact)
    c:RegisterEffect(e1) 
    --Destroy Spell/Trap
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_ACTIVATE)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetHintTiming(0,TIMING_END_PHASE)
    e2:SetCountLimit(1,id)
    e2:SetCondition(s.spellcon)
    e2:SetCost(s.descost)
    e2:SetTarget(s.destg)
    e2:SetOperation(s.desact)
    c:RegisterEffect(e2)
    --return to GY and search
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_REMOVED)
    e3:SetCountLimit(1,id)
    e3:SetTarget(s.thtg)
    e3:SetOperation(s.thop)
    c:RegisterEffect(e3)
end
--Functions
function s.costfilter(c,tp)
    return c:IsSetCard(0x584) and c:IsAbleToRemoveAsCost()
end
function s.spellconfilter(c)
    return (c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsType(TYPE_CONTINUOUS)) and c:IsFaceup() and c:IsSetCard(0x584)
end
function s.monconfilter(c)
    return c:IsType(TYPE_MONSTER) and c:IsFaceup() and c:IsSetCard(0x584)
end
function s.destgfilter(c)
    return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsDestructable()
end
function s.montgfilter(c)
    return c:IsType(TYPE_MONSTER) and c:IsDestructable()
end
function s.spellcon(e,tp,eg,ep,ev,re,r,rp)
    if c==nil then return true end
    local tp=c:GetControler()
    return Duel.IsExistingMatchingCard(s.spellconfilter,tp,LOCATION_SZONE,0,1,nil)
end
function s.moncon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.monconfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,nil)
    Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsOnField() and s.destgfilter(chkc) and chkc~=e:GetHandler() end
    if chk==0 then return Duel.IsExistingTarget(s.destgfilter,tp,0,LOCATION_ONFIELD,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
    local g=Duel.SelectTarget(tp,s.destgfilter,tp,0,LOCATION_ONFIELD,1,2,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.montg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsOnField() and s.montgfilter(chkc) and chkc~=e:GetHandler() end
    if chk==0 then return Duel.IsExistingTarget(s.montgfilter,tp,0,LOCATION_ONFIELD,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectTarget(tp,s.montgfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.desact(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.Destroy(tc,REASON_EFFECT)
    end
end
function s.thfilter(c,g)
    return c:IsSetCard(0x584) and c:IsAbleToHand() and not c:IsCode(3074153)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsAbleToGrave() end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,e:GetHandler(),1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
    Duel.SendtoGrave(c,REASON_EFFECT+REASON_RETURN)
    Duel.BreakEffect()
    local g=Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end
end

--[[
Name: Intergalactic Meteors
Attribute: TRAP
Type: [Trap/Normal]
Card Text: Banish 1 "Intergalactic" card from your hand; Activate 1 of the effects based on the face up "Intergalactic" cards you control.
           ● Monster: Target 1 face-up monster your opponent controls; destroy it.
           ● Spell/Trap: Then target up to 2 Spells/Traps your opponent controls; destroy them.
           During your Main Phase: You can return this banished card to the GY; add 1 "Intergalactic" card from your Deck to your hand,
           except "Intergalactic Meteors". If this card is destroyed by an opponent's card effect: You can set this card face-down. You
           can only use each effect of "Intergalactic Meteors" once per turn.
Card ID: 03074153
--]]

-- Scripted by: Yu-Gi-Oh! Customs Samurai