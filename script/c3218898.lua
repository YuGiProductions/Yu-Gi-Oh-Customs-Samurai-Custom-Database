--追放されたエンチャントメント - ガイダンス

local s,id=GetID()
function s.initial_effect(c)
    --Special Summon, but effect negated
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
    
    --Banish 1 opponent's monster
    local e2=Effect.CreateEffect(c)
    e2:SetCountLimit(1,id)
    e2:SetRange(LOCATION_REMOVED)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetCost(s.bancos)
    e2:SetTarget(s.bantg)
    e2:SetOperation(s.banop)
    c:RegisterEffect(e2)
 end
    
--Functions
s.listed_series={0x584}

function s.filter(c,e,tp)
    return c:IsSetCard(0x584) and c:IsCanBeSpecialSummoned(e,0,tp,true,false) and c:IsMonster() and not c:IsCode(3218888)
end

function s.cfilter(c)
    return c:IsFaceup() and c:IsAbleToRemove()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
    local tc=g:GetFirst()
    if tc and Duel.SpecialSummonStep(tc,0,tp,tp,true,false,POS_FACEUP) then
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_DISABLE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e1,true)
        local e2=Effect.CreateEffect(e:GetHandler())
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_DISABLE_EFFECT)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e2,true)
    end
    Duel.SpecialSummonComplete()
end

function s.bancos(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_RETURN)
end

function s.bantg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c:IsAbleToRemove() and chkc:IsFaceup() end
    if chk==0 then return Duel.IsExistingTarget(s.cfilter,tp,0,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectTarget(tp,s.cfilter,tp,0,LOCATION_MZONE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end

function s.banop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) then
        Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
    end
end

--[[
Name: Banished Enchantment - Guidance

Attribute: SPELL

Type: [Spell/Normal]

Card Text: Special Summon 1 "Lord of the Banished Realm" monster from your hand, but its effects are negated until the End
           Phase. During your Main Phase: You can return this banished card to the GY and target 1 face-up monster your
           opponent controls; banish it. You can only use this effect of "Banished Enchantment - Guidance" once per turn.

Card ID: 03218898
--]]

-- Scripted by: Yu-Gi-Oh! Customs Samurai