--銀河間ガードドッグ

local s,id=GetID()
function s.initial_effect(c)
    --search
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	
	--Negate attack then effects
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,id)
	e2:SetHintTiming(0,TIMING_ATTACK)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(s.condition)
	e2:SetCost(aux.bfgcost)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
	
--Functions
function s.thfilter(c)
	return c:IsSetCard(0x584) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp and (Duel.IsAbleToEnterBP() or (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE))
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetAttacker() then Duel.NegateAttack()
	else
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_ATTACK_ANNOUNCE)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetOperation(s.disop)
		Duel.RegisterEffect(e1,tp)
	end
		local c=e:GetHandler()
	local ct=e:GetLabel()
	local sg=Duel.GetMatchingGroup(aux.FilterFaceupFunction(Card.IsType,TYPE_EFFECT),tp,0,LOCATION_MZONE,nil)
	if #sg<ct then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
	local g=sg:Select(tp,ct,ct,nil)
	for tc in aux.Next(g) do
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end

--[[
Name: Intergalactic Guard Dog
Attribute: EARTH
Level: 03
Type: [Beast/Effect]
Card Text: When this card is Normal Summoned: You can add 1 "Intergalactic" Spell/Trap from your Deck to your hand. During your opponent's turn, when your
           opponent declares an attack: You can banish this card from your GY; negate the attack, and if you do, that monster's effects are negated until
           the End Phase. You can only use each effect of "Intergalactic Guard Dog" once per turn.
ATK: 1400
DEF: 500
Card ID: 03071303
--]]

-- Scripted by: Yu-Gi-Oh! Customs Samurai