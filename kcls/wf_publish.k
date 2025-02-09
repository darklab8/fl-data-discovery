import infra.kcls.models.github_action as ga
import infra.kcls.models.github_workflow as gw
import infra.kcls.common.github as ghc
import infra.kcls.actions.checkout_freelancer as cf
import infra.kcls.actions.install_go
import infra.kcls.actions.darkstat

_freelancer_folder = r"${{ github.workspace }}/freelancer_folder"

_workflow = gw.Workflow {
    _filename = "publish.yaml"
    name = "Publish"
    on = {
        workflow_dispatch: {}
        push.branches = ["master"]
        schedule:[{cron="0 10,15,20 * * *"}]
        repository_dispatch: {types: ["publish"]}
    }
    jobs = {
        job = _publish_job
    }
}
_publish_job: gw.Job = {
    name = "Github Pages"
    permissions: ghc.PagesPermissions {}
    environment: dict(ghc.PagesEnvironment {})
    steps = [
        ghc.CheckoutRepo
        ga.Step{
            name = "Download lock file"
            run = "wget https://patch.discoverygc.com/patchlist.xml"
        }
        ga.Step {
            name = "Cache Freelancer"
            id = "cache-freelancer"
            uses = "actions/cache@v3"
            with= {
                key = r"${{ runner.os }}-freelancer-discovery-${{ hashFiles('patchlist.xml') }}"
                path = _freelancer_folder
            }
        }
        cf.NewCheckoutFreelancer(cf.CheckoutArgs {
            freelancer_mod = cf._mod_discovery
            freelancer_folder = _freelancer_folder
            $if = r"${{ steps.cache-freelancer.outputs.cache-hit != 'true' }}"
        })
        install_go.InstallGo{}
        ga.Step{
            name = "Patch to latest"
            run = "go run autopatch.go -wd ${_freelancer_folder}"
        }
        ga.Step{
            name = "temporal fix to disco bugs"
            shell = "python"
            run = """filename = "${_freelancer_folder}/DATA/initialworld.ini"
with open(filename, "r") as file:
    data = file.read()

replaced = data.replace("rep = 0.-55, gd_im_grp", "rep = -0.55, gd_im_grp")

with open(filename, "w") as file:
    file.write(replaced)
"""
        }
        darkstat.Build(darkstat.BuildArgs{
            site_host = "https://darkstat.dd84ai.com"
            site_root = "/fl-data-discovery/"
            freelancer_folder = _freelancer_folder
            heading = '<a href="https://github.com/darklab8/fl-darkstat">Darkstat</a> from <a href="https://darklab8.github.io/blog/pet_projects.html#Freelancercommunity">DarkTools</a> for <a href="https://github.com/darklab8/fl-data-discovery">Freelancer Discovery</a>'
            relay_host = "https://darkrelay.dd84ai.com"
            apigateway_host = "https://apigateway.dd84ai.com"
        })
    ]  + ghc.PagesToDeploySteps(ghc.PagesDeployOpts {})
}
