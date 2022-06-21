--追放された王国の知識人 - 司書

local s,id=GetID()
function s.initial_effect(c)
    --Search 1 Spell/Trap
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)	
end

--Functions
function s.thfilter(c,cd)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand() and c:IsSetCard(0x584) and not c:IsCode(cd)
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end

function s.cfilter(c,tp)
	return c:IsSetCard(0x584) and c:IsFaceup() and c:IsAbleToDeckAsCost()
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,c,c:GetCode())

end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_REMOVED,0,1,e:GetHandler(),tp)
	end
	e:SetLabel(0)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_REMOVED,0,1,1,e:GetHandler(),tp)
	e:SetLabelObject(g:GetFirst())
	Duel.SendtoDeck(g,nil,2,REASON_EFFECT)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,2,tp,LOCATION_REMOVED)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local sc=e:GetLabelObject()
	local g1=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK,0,sc,sc:GetCode())
	if #g1==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=g1:Select(tp,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	if #g==1 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-tp,g)
	end
end


--[[
Name: Intelord of the Banished Realm - Librarian

Attribute: LIGHT

Level: 04

Type: [Fairy/Effect]

Card Text: Once per turn: You can shuffle 1 of your banished "Banished Enchantment" Spell/Trap Cards into the Deck; add
           1 "Banished Enchantment" Spell/Trap from your Deck to your hand, except a card with the same name as the card
           shuffled into the Deck by this effect.

ATK: 1800   DEF: 1000   Card ID: 03218891
--]]

-- Scripted by: Yu-Gi-Oh! Customs Samurai