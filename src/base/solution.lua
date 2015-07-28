---
-- solution.lua
-- Work with the list of solutions loaded from the script.
-- Copyright (c) 2002-2015 Jason Perkins and the Premake project
---

	local p = premake
	p.solution = p.api.container("solution", p.global)

	local solution = p.solution
	local tree = p.tree


---
-- Begin the switch from solution() to workspace()
---

	p.workspace = p.solution
	local workspace = p.solution

	p.alias(_G, "solution", "workspace")
	p.alias(_G, "externalsolution", "externalworkspace")



---
-- Create a new solution container instance.
---

	function workspace.new(name)
		local sln = p.container.new(workspace, name)
		return sln
	end



--
-- Iterate over the configurations of a solution.
--
-- @param sln
--    The solution to query.
-- @return
--    A configuration iteration function.
--

	function workspace.eachconfig(sln)
		sln = premake.oven.bakeSolution(sln)

		local i = 0
		return function()
			i = i + 1
			if i > #sln.configs then
				return nil
			else
				return sln.configs[i]
			end
		end
	end


--
-- Iterate over the projects of a solution (next-gen).
--
-- @param sln
--    The solution.
-- @return
--    An iterator function, returning project configurations.
--

	function workspace.eachproject(sln)
		local i = 0
		return function ()
			i = i + 1
			if i <= #sln.projects then
				return p.workspace.getproject(sln, i)
			end
		end
	end


--
-- Locate a project by name, case insensitive.
--
-- @param sln
--    The solution to query.
-- @param name
--    The name of the projec to find.
-- @return
--    The project object, or nil if a matching project could not be found.
--

	function workspace.findproject(sln, name)
		name = name:lower()
		for _, prj in ipairs(sln.projects) do
			if name == prj.name:lower() then
				return prj
			end
		end
		return nil
	end


--
-- Retrieve the tree of project groups.
--
-- @param sln
--    The solution to query.
-- @return
--    The tree of project groups defined for the solution.
--

	function workspace.grouptree(sln)
		-- check for a previously cached tree
		if sln.grouptree then
			return sln.grouptree
		end

		-- build the tree of groups

		local tr = tree.new()
		for prj in workspace.eachproject(sln) do
			local prjpath = path.join(prj.group, prj.name)
			local node = tree.add(tr, prjpath)
			node.project = prj
		end

		-- assign UUIDs to each node in the tree
		tree.traverse(tr, {
			onnode = function(node)
				node.uuid = os.uuid(node.path)
			end
		})

		sln.grouptree = tr
		return tr
	end


--
-- Retrieve the project configuration at a particular index.
--
-- @param sln
--    The solution.
-- @param idx
--    An index into the array of projects.
-- @return
--    The project configuration at the given index.
--

	function workspace.getproject(sln, idx)
		sln = p.oven.bakeSolution(sln)
		return sln.projects[idx]
	end



---
-- Determines if the solution contains a project that meets certain criteria.
--
-- @param self
--    The solution.
-- @param func
--    A test function. Receives a project as its only argument and returns a
--    boolean indicating whether it meets to matching criteria.
-- @return
--    True if the test function returned true.
---

	function solution.hasProject(self, func)
		return p.container.hasChild(self, p.project, func)
	end
