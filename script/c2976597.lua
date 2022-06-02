--コズミックドラゴン、シンダー

local s,id=GetID()
function s.initial_effect(c)
    --Synchro Summon
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)
	c:EnableReviveLimit()

    --Activation Discard Negate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.discon)
	e1:SetCost(s.discost)
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	e1:SetCountLimit(1,{id,1})
	c:RegisterEffect(e1)

    --Opponent discards during MP2 if this card didn't attack on your turn
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_HANDES)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.con)
	e2:SetTarget(s.target)
	e2:SetOperation(s.activate)
	e2:SetCountLimit(1,{id,1})
	c:RegisterEffect(e2)
end

--Functions
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    if e:GetHandler():IsRelateToEffect(e) then
        e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,0)
        local g=Duel.GetFieldGroup(1-tp,LOCATION_HAND,0)
        if #g==0 then return end
            Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_DISCARD)
            sg=g:Select(1-tp,1,1,nil)
            Duel.SendtoGrave(sg,REASON_EFFECT+REASON_DISCARD)
    end
end

function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and re:GetHandler()~=e:GetHandler() and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(ev) and Duel.IsTurnPlayer(1-tp)
end

function s.cfilter(c)
    return c:IsType(TYPE_TRAP) and c:IsDiscardable()
end

function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) end
    Duel.DiscardHand(tp,s.cfilter,1,1,REASON_COST+REASON_DISCARD)
end

function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) and re:GetHandler():IsDestructable() then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end

function s.disop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
        Duel.Destroy(eg,REASON_EFFECT)
    end
end

function s.con(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase(tp)==PHASE_MAIN2 and e:GetHandler():GetAttackAnnouncedCount()==0
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
    Duel.SetTargetPlayer(tp)
    Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,1-tp,2)
end

--[[
Name: Cosmic Dragon, Cinder

Attribute: FIRE

Level: 06

Type: [Dragon/Synchro/Effect]

Card Text: 1 Tuner + 1+ non-Tuner monsters
           During your opponent's turn, when your opponent activates a Spell/Trap Card or monster effect (Quick Effect): You can
           discard 1 Trap; negate the activation, and if you do, destroy it. During your Main Phase 2, if this card did not attack
           this turn: You can make your opponent discard 1 card. You can only use each effect of "Cosmic Dragon, Cinder" once per turn.
           
ATK: 2600   DEF: 1500   Card ID: 02976597
--]]

-- Scripted by: Yu-Gi-Oh! Customs Samurai