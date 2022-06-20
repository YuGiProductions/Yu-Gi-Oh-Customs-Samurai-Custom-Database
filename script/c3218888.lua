--追放された王国の君主 - 全能

local s,id=GetID()
function s.initial_effect(c)
	--Cannot Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	
	--Special Summon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(s.spcon)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	
	--Indestructible by Card Effects
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	
	--Gains ATK
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetValue(s.atkval)
	c:RegisterEffect(e4)
	
	--Avoid Battle Destruction
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_DESTROY_REPLACE)
	e5:SetCountLimit(1,id)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTarget(s.reptg)
	e5:SetValue(s.repval)
	c:RegisterEffect(e5)
	
	--Negate
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,1))
	e6:SetCategory(CATEGORY_NEGATE)
	e6:SetType(EFFECT_TYPE_QUICK_O)
	e6:SetCode(EVENT_CHAINING)
	e6:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCountLimit(1,id)
	e6:SetCondition(s.discon)
	e6:SetTarget(s.distg)
	e6:SetOperation(s.disop)
	c:RegisterEffect(e6)
end
	
--Functions
s.listed_series={0x584}

function s.cfilter(c)
	return not c:IsAbleToDeckOrExtraAsCost()
end

function s.spfilter(c)
    return  c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end

function s.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
		and c:IsType(TYPE_SPELL+TYPE_TRAP) and not c:IsReason(REASON_REPLACE) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end

function s.spcon(e,c)
    if c==nil then return true end
    if Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)<=0 then return false end
    local g=Duel.GetMatchingGroup(s.spfilter,c:GetControler(),LOCATION_REMOVED,0,nil)
    return #g>3 and not g:IsExists(s.cfilter,1,nil)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
    local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_REMOVED,0,nil)
    Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end

function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsReason(REASON_BATTLE) and Duel.IsExistingMatchingCard(s.repfilter,tp,LOCATION_GRAVE,0,1,nil) end
    if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
        local g=Duel.SelectMatchingCard(tp,s.repfilter,tp,LOCATION_GRAVE,0,1,1,nil)
        Duel.Remove(g,POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
        return true
    else return false end
end

function s.repfilter(c)
    return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToRemoveAsCost() and c:IsSetCard(0x584)
end

function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end

function s.discon(e,tp,eg,ep,ev,re,r,rp)
    return rp~=tp and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end

function s.discost(e,te_or_c,tp)
    local ct=#{Duel.GetPlayerEffect(tp,id)}
    return Duel.CheckLPCost(tp,ct*500)
end

function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
    if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
        Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,1,0,0)
    end
end

function s.disop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsFacedown() or c:GetAttack()<500 or not c:IsRelateToEffect(e) or Duel.GetCurrentChain()~=ev+1 or c:IsStatus(STATUS_BATTLE_DESTROYED) then
        return
    end
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_COPY_INHERIT)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(-500)
    c:RegisterEffect(e1)
    if not c:IsImmuneToEffect(e1) and not c:IsHasEffect(EFFECT_REVERSE_UPDATE) then
            if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
                Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
            end
    end
end

function s.atkfilter(c)
    return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSetCard(0x584)
end

function s.atkval(e,c)
    return Duel.GetMatchingGroupCount(aux.FilterFaceupFunction(s.atkfilter),c:GetControler(),LOCATION_REMOVED,0,nil)*1000
end

--[[
Name: Overlord of the Banished Realm - Omnipotence

Attribute: LIGHT

Level: 11

Type: [Fairy/Effect]

Card Text: Cannot be Normal Summoned/Set. Must first be Special Summoned (from your hand) by shuffling all of your banished
           Spell/Trap cards (min. 4) into the Deck. Cannot be destroyed by card effects. This card gains ATK equal to the
           number of banished "Banished Enchantment" cards x 1000. You can only use each of the following effects of "Overlord
           of the Banished Realm - Omnipotence" once per turn. If this card would be destroyed by battle, you can banish 1 "Banished Enchantment"
           Spell/Trap from your GY instead. During your opponent's turn, when your opponent activates a Spell/Trap Card or monster
           effect (Quick Effect): You can make this card lose 500 ATK; negate the activation, and if you do, banish it.

ATK: ?   DEF: 2800   Card ID: 03218888
--]]

-- Scripted by: Yu-Gi-Oh! Customs Samurai