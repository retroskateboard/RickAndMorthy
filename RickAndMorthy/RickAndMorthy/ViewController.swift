//
//  ViewController.swift
//  RickAndMorthy
//
//  Created by Eric Rojas Pech on 01/12/23.
//

import UIKit

class ViewController: UIViewController {
   
    var currentPage: Int = 2

    let restClient = RESTClient<PaginatedResponse<Character>>(client: Client(baseUrl: "https://rickandmortyapi.com"))
    
    var characters: [Character]? {
        didSet {
            tableView.reloadData()
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.prefetchDataSource = self
        restClient.show("/api/character/", page: 1) { response in
                self.characters = response.results
        }
    }
}



extension ViewController: UITableViewDataSource {

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return characters?.count ?? 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        
        cell.textLabel?.text = characters?[indexPath.row].name
        cell.detailTextLabel?.text = characters?[indexPath.row].species
        
        return cell
    }
}

extension ViewController: UITableViewDataSourcePrefetching {
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        guard let characters = characters else { return }
        let needsFetch = indexPaths.contains { $0.row >= characters.count - 1 }
        
        if needsFetch {
            restClient.show("/api/character/", page: currentPage) { response in
                self.characters?.append(contentsOf: response.results)
            }
            currentPage += 1
        }
    }
}
