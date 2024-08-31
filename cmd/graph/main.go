package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/shurcooL/githubv4"
	"github.com/sirupsen/logrus"
	"golang.org/x/oauth2"
	"gonum.org/v1/plot"
	"gonum.org/v1/plot/plotter"
	"gonum.org/v1/plot/plotutil"
	"gonum.org/v1/plot/vg"
	"gopkg.in/yaml.v2"
)

func main() {
	if err := core(); err != nil {
		log.Fatal(err)
	}
}

func core() error {
	// start: 2021-09-02 https://github.com/aquaproj/aqua-registry/commit/199bdfb520dcb27f3338cc0fb01ce525c12c21c7
	startDate := time.Date(2021, 9, 2, 3, 49, 0, 0, time.UTC)

	ctx := context.Background()

	// list releases
	src := oauth2.StaticTokenSource(
		&oauth2.Token{AccessToken: os.Getenv("GITHUB_TOKEN")},
	)
	httpClient := oauth2.NewClient(ctx, src)
	client := githubv4.NewClient(httpClient)
	logrus.Infof("getting the list of releases")

	releases, err := listReleases(ctx, client)
	if err != nil {
		return err
	}

	logrus.WithField("num_of_releases", len(releases)).Info("got the list of releases")

	pts, err := getPlots(ctx, startDate, releases)
	if err != nil {
		return err
	}

	return draw(pts)
}

func getPlots(ctx context.Context, startDate time.Time, releases []*Release) (plotter.XYs, error) {
	pts := make(plotter.XYs, len(releases))
	for i, release := range releases {
		duration := release.PublishedAt.Sub(startDate).Hours() / 24
		name := *release.Name
		logrus.WithFields(logrus.Fields{
			"release":      name,
			"published_at": release.PublishedAt,
			"duration":     duration,
		}).Info("getting the number of packages")
		numOfPkgs, err := getNumOfPackages(ctx, release)
		if err != nil {
			return nil, err
		}
		logrus.WithFields(logrus.Fields{
			"release":         name,
			"published_at":    release.PublishedAt,
			"num_of_packages": numOfPkgs,
			"duration":        duration,
		}).Info("got the number of packages")
		pts[i].X = duration
		pts[i].Y = float64(numOfPkgs)
	}
	return pts, nil
}

type Release struct {
	Name        *githubv4.String
	PublishedAt *githubv4.DateTime
}

func listReleases(ctx context.Context, client *githubv4.Client) ([]*Release, error) {
	var q struct {
		Repository struct {
			Releases struct {
				Nodes    []*Release
				PageInfo struct {
					EndCursor   githubv4.String
					HasNextPage bool
				}
			} `graphql:"releases(first: 100, after: $releasesCursor)"`
		} `graphql:"repository(owner: $repositoryOwner, name: $repositoryName)"`
	}
	variables := map[string]interface{}{
		"repositoryOwner": githubv4.String("aquaproj"),
		"repositoryName":  githubv4.String("aqua-registry"),
		"releasesCursor":  (*githubv4.String)(nil), // Null after argument to get first page.
	}

	var allReleases []*Release
	for {
		if err := client.Query(ctx, &q, variables); err != nil {
			return nil, fmt.Errorf("list releases by GitHub API: %w", err)
		}
		allReleases = append(allReleases, q.Repository.Releases.Nodes...)
		if !q.Repository.Releases.PageInfo.HasNextPage {
			break
		}
		variables["releasesCursor"] = githubv4.NewString(q.Repository.Releases.PageInfo.EndCursor)
	}
	return allReleases, nil
}

func draw(pts plotter.XYs) error {
	p := plot.New()
	path := "points.png"

	p.Title.Text = "The transition of the number of packages"
	p.X.Label.Text = "Date and aqua-registry version"
	p.Y.Label.Text = "The number of packages"

	if err := plotutil.AddLinePoints(p, pts); err != nil {
		return fmt.Errorf("add a line points to the plot: %w", err)
	}

	logrus.Info("saving the plot to a PNG file")
	if err := p.Save(4*vg.Inch, 4*vg.Inch, path); err != nil {
		return fmt.Errorf("save the plot to a PNG file: %w", err)
	}
	return nil
}

type Registry struct {
	Packages []struct{}
}

func getNumOfPackages(ctx context.Context, release *Release) (int, error) {
	u := fmt.Sprintf("https://raw.githubusercontent.com/aquaproj/aqua-registry/%s/registry.yaml", *release.Name)
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, u, nil)
	if err != nil {
		return 0, nil
	}
	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return 0, nil
	}
	defer resp.Body.Close()
	registry := &Registry{}
	if err := yaml.NewDecoder(resp.Body).Decode(registry); err != nil {
		return 0, err
	}
	return len(registry.Packages), nil
}
