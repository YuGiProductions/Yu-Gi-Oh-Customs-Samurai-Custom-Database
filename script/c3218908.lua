--追放されたエンチャントメント - 無効化

local s,id=GetID()
function s.initial_effect(c)
    --Negate
	local e1=Effect.CreateEffect(c)
	e1:SetCountLimit(1,id)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCost(s.cost)
	e1:SetCondition(s.con)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	
	--Negate all monster effects until End Phase
	local e2=Effect.CreateEffect(c)
    e2:SetCode(EFFECT_DISABLE)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_REMOVED)
    e2:SetCost(s.bancos)
    e2:SetTarget(s.bantg)
    e2:SetOperation(s.banop)
    c:RegisterEffect(e2)
end

--Functions
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetDecktopGroup(tp,2)
	if chk==0 then return g:FilterCount(Card.IsAbleToRemoveAsCost,nil,POS_FACEDOWN)==2
		and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=2 end
	Duel.DisableShuffleCheck()
	Duel.Remove(g,POS_FACEDOWN,REASON_COST)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,1,0,0)
	end
end

function s.con(e,tp,eg,ep,ev,re,r,rp)
    return ep~=tp and Duel.IsChainDisablable(ev)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
	end
end

function s.bancos(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_RETURN)
end

function s.bantg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(aux.disfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
end

function s.banop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(aux.disfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
    local c=e:GetHandler()
    for tc in g:Iter() do
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_DISABLE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e1)
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_DISABLE_EFFECT)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e2)
    end
end

--[[
Name: Banished Enchantment - Nullification

Attribute: TRAP

Type: [Trap/Counter]

Card Text: When your opponent activates a Spell/Trap Card or effect: Banish the top 2 cards of your Deck facedown; negate
           the activation, and if you do, banish that card. You can only use this effect of "Banished Enchantment - Nullification"
           once per turn. During your Main Phase: You can return this banished card to the GY; negate the effects of all monsters
           currently on the field until the End Phase.
           
Card ID: 03218908
--]]

-- Scripted by: Yu-Gi-Oh! Customs Samurai
