/**
 * vim: set ts=4 :
 * =============================================================================
 * NativeVotes Basecommands Plugin
 * Provides cancelvote functionality.
 *
 * SourceMod (C)2004-2008 AlliedModders LLC.  All rights reserved.
 * =============================================================================
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License, version 3.0, as published by the
 * Free Software Foundation.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * As a special exception, AlliedModders LLC gives you permission to link the
 * code of this program (as well as its derivative works) to "Half-Life 2," the
 * "Source Engine," the "SourcePawn JIT," and any Game MODs that run on software
 * by the Valve Corporation.  You must obey the GNU General Public License in
 * all respects for all other code used.  Additionally, AlliedModders LLC grants
 * this exception to all derivative works.  AlliedModders LLC defines further
 * exceptions, found in LICENSE.txt (as of this writing, version JULY-31-2007),
 * or <http://www.sourcemod.net/license.php>.
 *
 * Version: $Id$
 */
 
#include <sourcemod>
#include <nativevotes>

#undef REQUIRE_PLUGIN
#include <adminmenu>

#define VERSION "1.0"

new Handle:hTopMenu;

public Plugin:myinfo = 
{
	name = "NativeVotes Basic Commands",
	author = "Powerlord and AlliedModders LLC",
	description = "Revote and Cancel support for NativeVotes",
	version = VERSION,
	url = "https://forums.alliedmods.net/showthread.php?t=208008"
}

public OnPluginStart()
{
	LoadTranslations("core.phrases");
	LoadTranslations("common.phrases");
	
	AddCommandListener(Command_CancelVote, "sm_cancelvote");
	AddCommandListener(Command_ReVote, "sm_revote");
}

bool:PerformCancelVote(client)
{
	if (!NativeVotes_IsVoteInProgress())
	{
		return false;
	}

	ShowActivity2(client, "[NV] ", "%t", "Cancelled Vote");
	
	NativeVotes_Cancel();
	return true;
}

public Action:Command_CancelVote(client, const String:command[], argc)
{
	if (!CheckCommandAccess(client, "sm_cancelvote", ADMFLAG_VOTE))
	{
		if (IsVoteInProgress())
		{
			// Let basecommands handle it
			return Plugin_Continue;
		}
		
		ReplyToCommand(client, "%t", "No Access");
		return Plugin_Handled;
	}
	
	if (PerformCancelVote(client))
	{
		return Plugin_Handled;
	}
	else
	{
		return Plugin_Continue;
	}
}

public AdminMenu_CancelVote(Handle:topmenu, 
							  TopMenuAction:action,
							  TopMenuObject:object_id,
							  param,
							  String:buffer[],
							  maxlength)
{
	if (action == TopMenuAction_DisplayOption)
	{
		Format(buffer, maxlength, "%T", "Cancel vote", param);
	}
	else if (action == TopMenuAction_SelectOption)
	{
		PerformCancelVote(param);
		RedisplayAdminMenu(topmenu, param);	
	}
	else if (action == TopMenuAction_DrawOption)
	{
		buffer[0] = NativeVotes_IsVoteInProgress() ? ITEMDRAW_DEFAULT : ITEMDRAW_IGNORE;
	}
}

public Action:Command_ReVote(client, const String:command[], argc)
{
	if (client == 0)
	{
		return Plugin_Continue;
	}
	
	if (!NativeVotes_IsVoteInProgress())
	{
		return Plugin_Continue;
	}
	
	if (!NativeVotes_IsClientInVotePool(client))
	{
		if (IsVoteInProgress())
		{
			// Let basecommands handle it
			return Plugin_Continue;
		}
		
		ReplyToCommand(client, "[NV] %t", "Cannot participate in vote");
		return Plugin_Handled;
	}
	
	if (NativeVotes_RedrawClientVote(client))
	{
		return Plugin_Handled
	}
	else if (!IsVoteInProgress())
	{
		ReplyToCommand(client, "[NV] %t", "Cannot change vote");
		return Plugin_Handled;
	}
	
	return Plugin_Continue;
}

public OnAdminMenuReady(Handle:topmenu)
{
	/* Block us from being called twice */
	if (topmenu == hTopMenu)
	{
		return;
	}
	
	/* Save the Handle */
	hTopMenu = topmenu;
	
	new TopMenuObject:voting_commands = FindTopMenuCategory(hTopMenu, ADMINMENU_VOTINGCOMMANDS);

	if (voting_commands != INVALID_TOPMENUOBJECT)
	{
		AddToTopMenu(hTopMenu,
			"sm_cancelvote",
			TopMenuObject_Item,
			AdminMenu_CancelVote,
			voting_commands,
			"sm_cancelvote",
			ADMFLAG_VOTE);
	}
}

public OnLibraryRemoved(const String:name[])
{
	if (strcmp(name, "adminmenu") == 0)
	{
		hTopMenu = INVALID_HANDLE;
	}
}
